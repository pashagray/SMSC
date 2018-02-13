# SMSC
[![Maintainability](https://api.codeclimate.com/v1/badges/9578c789a2f4a6e8881a/maintainability)](https://codeclimate.com/github/PavelTkachenko/SMSC/maintainability)

Обертка над сервисом smsc.kz.

- [x] Проверка баланса
- [x] Отправка SMS-сообщений
- [x] Отправка flash SMS-сообщений (всплывающих на экране)
- [x] Транслит/Оригинальный текст
- [x] Трансформация ссылкок в сообщении в короткие
- [-] Отправка отложенных SMS-сообщений (с указанием времени) 
- [-] Отправка MMS
- [-] Отправка EMAIL
- [-] Звонок
- [x] Получение статуса сообщений
- [x] Пинг (отправка пустого сообщения, которое не видит пользователь, для проверки доступности)
- [-] Интеграция с i18n
- [-] Коллбэки (on_send, after_send)

## Установка

```ruby
gem 'smsc'
```

## Как пользоваться?

TODO: Генератор для Rails

Результатом любого запроса является монада `Success` или `Failure`. Получить значение можно вызвав `value` на результат. Проверить, является ли запрос успешным можно методом `success?`. В `Failure` будет передан ключ ошибки (см. Ошибки). 

### Конфигурация

#### Для Rails

Просто создайте файл `smsc.rb` в `config/initializers`. Если файл не создать, то необходимо указывать логин и пароль при каждом запросе.

```ruby
# config/initializers/smsc.rb

SMSC.configure do |config|
  config.login = "your_login"
  config.password = "your_passsword"
end

```

#### Для Rails хэйтеров

Вы и сами знаете, что делать ;)

### Проверка баланса

Проверка баланса на аккаунте. Возвращаеся сумма и валюта в формате  ISO4217.

```ruby
request = SMSC::Balance.new
result = request.call
if result.success?
  puts result.value #=> { balance: 1000.0, cur: "KZT" }
else
  # choose how to handle error, for example just puts it!
  puts result.value
end

```

### Отправка СМС

Отправка СМС на указанный номер с указанным сообщением. Можно передавать телефоны в любом формате, гем попытается привести их к необходимому значению. По умолчанию СМС отправляется в транслите. Аргумент `translit: false` в `call` сделает отправку в оригинале (UTF-8). В случае успеха будет возвращено `id` сообщения. Его можно использовать в дальнейшем для проверки статуса.

```ruby
request = SMSC::Send.new
result = request.call(phone: '+7 (777) 777-77-77', message: "Следуй за белым кроликом...")
if result.success?
  puts result.value #=> { id: 1, cnt: 1 }
else
  puts result.value
end
```

#### Отправка Flash-SMS

Такое сообщение будет выведено сразу на экран мобильного телефона (в виде попапа). Обычно используется только в экстренных случаях (службы спасения и т.д.)

```ruby
request = SMSC::Send.new
result = request.call(phone: '+7 (777) 777-77-77', flash: true, message: "Внимание!")
if result.success?
  puts result.value #=> { id: 1, cnt: 1 }
else
  puts result.value
end

```

### Пинг-сообщение

Отправка пустого сообщения (адресат его не видит), для проверки доступности. ВНИМАНИЕ! Взымается плата стоимостью в 1 СМС. По указанным сообщениям можно также проверить статус.

```ruby
request = SMSC::Ping.new
result = request.call(phone: '+7 (777) 777-77-77')
if result.success?
  puts result.value #=> { id: 1, cnt: 1 }
else
  puts result.value
end
```

### Статус сообщения

Получение информации о сообщении по номеру адресата и id сообщения.

```ruby
request = SMSC::Status.new
result = request.call(phone: '+7 (777) 777-77-77', id: 1)
if result.success?
  result.value
  # {
  #   cost: 6.4,
  #   country: "Казахстан",
  #   message: "Test",
  #   operator: "K'cell",
  #   phone: "77777777777",
  #   region: "",
  #   send_timestamp: 2018-02-12 18:34:17 +0600,
  #   sender_id: "SMSC.KZ",
  #   status: :delivered,
  #   type: :sms
  # }
else
  puts result.value
end

```

#### Возможные статусы

В настоящий момент возвращаются коды статусов, без переводов. Перевод нужно сделать самостоятельно или дождаться интеграции с i18n. Contributors are welcome!

| Код статуса | Описание | Расшифровка |
| --- | --- | --- |
| `:not_found` |  Сообщение не найдено | Возникает, если для указанного номера телефона и ID сообщение не найдено. |
| `:in_provider_queue` |  Ожидает отправки | Если при отправке сообщения было задано время получения абонентом, то до этого времени сообщение будет находиться в данном статусе, в других случаях сообщение в этом статусе находится непродолжительное время перед отправкой на SMS-центр. |
| `:in_operator_queue` |  Передано оператору |  Сообщение было передано на SMS-центр оператора для доставки. |
| `:delivered` |  Доставлено |  Сообщение было успешно доставлено абоненту. |
| `:opened` |  Прочитано |    Сообщение было прочитано (открыто) абонентом. Данный статус возможен для e-mail-сообщений, имеющих формат html-документа. (TODO) |
| `:expired` |  Просрочено |    Возникает, если время "жизни" сообщения истекло, а оно так и не было доставлено получателю, например, если абонент не был доступен в течение определенного времени или в его телефоне был переполнен буфер сообщений. |
| `:unable_to_deliver` | Невозможно доставить | Попытка доставить сообщение закончилась неудачно, это может быть вызвано разными причинами, например, абонент заблокирован, не существует, находится в роуминге без поддержки обмена SMS, или на его телефоне не поддерживается прием SMS-сообщений. |
| `:wrong_number` | Неверный номер | Неправильный формат номера телефона. |
| `:prohibited` | Запрещено | Возникает при срабатывании ограничений на отправку дублей, на частые сообщения на один номер (флуд), на номера из черного списка, на запрещенные спам фильтром тексты или имена отправителей (Sender ID). |
| `:insufficient_funds` | Недостаточно средств | На счете Клиента недостаточная сумма для отправки сообщения. |
| `:unreachable_number` | Недоступный номер | Телефонный номер не принимает SMS-сообщения, или на этого оператора нет рабочего маршрута. |

### Ошибки

При неудачном запросе возвращается результат `Failure`. При вызове метода `success?` на него, будет возвращено `false`. Для получения кода ошибки нужно вызвать метод `value` на результат.

#### Коды ошибок

| Код статуса | Описание | Расшифровка |
| --- | --- | --- |
| `:network_error` | Ошибка сети | DNS/Сервис не доступен. Или началась глобальная война. |
| `:bad_parameters` | Неверные параметры | Указанные в `call` параметры не верны. |
| `:wrong_credentials` | Недостаточно средств | На счете Клиента недостаточная сумма для выполнения операции. |
| `:insufficient_funds` | Ошибка аутентификации | Логин или пароль указаны не верно. |
| `:too_many_errors` | Много ошибок |   IP-адрес временно заблокирован из-за частых ошибок в запросах. |
| `:message_is_prohibited` | Сообщение заблокировано | Сообщение запрещено (по тексту или по имени отправителя). |
| `:frequent_requests` | Частые запросы | Отправка более одного одинакового запроса на передачу SMS-сообщения либо более пяти одинаковых запросов на получение стоимости сообщения в течение минуты. |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/smsc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SMSC project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/smsc/blob/master/CODE_OF_CONDUCT.md).
