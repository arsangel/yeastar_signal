# yeastar_signal# Project: Reading SMS on Yeastar TG-Series (TG200, TG400, TG800, TG1600) and Forwarding to Signal Messenger
This project aims to utilize the capabilities of Yeastar TG-Series VoIP GSM gateways—specifically models TG200, TG400, TG800, and TG1600—to read incoming SMS messages and subsequently forward them to Signal Messenger. These gateways offer robust features for managing SMS through various interfaces, including web-based platforms and APIs. By integrating with Signal Messenger, users can centralize their messaging platforms, enhancing communication efficiency.

## Основные функции скрипта:
1.	Подключение к Yeastar через AMI для мониторинга SMS:
Скрипт устанавливает соединение с устройством Yeastar посредством протокола Asterisk Management Interface (AMI) для отслеживания поступления новых SMS-сообщений.
2.	Обработка и сохранение входящих SMS:
При получении нового SMS скрипт создает текстовый файл в директории /tmp/sms.
Содержимое каждого файла включает номер отправителя и текст сообщения.
3.	Периодическая проверка директории и отправка сообщений в Signal Messenger:
Каждые 10 секунд скрипт проверяет наличие новых файлов в директории /tmp/sms.
Обнаруженные файлы обрабатываются для отправки соответствующих сообщений в Signal Messenger.
После успешной отправки сообщения соответствующий файл удаляется из директории.

## Аппаратные требования для интеграции с Yeastar TG-Series (TG200, TG400, TG800):
1.	Оборудование:
GSM-шлюзы Yeastar TG-Series: TG200, TG400 или TG800.
SIM-карты: Установлены в соответствующие слоты шлюза и не защищены PIN кодом.
Sim карта имее положительный баланс и способныа принимать SMS-сообщения.
2.	Сетевые настройки:
Подключение к локальной сети: Шлюз должен быть подключен к сети с доступом к необходимым сервисам.
Разрешенные IP-адреса: 
	Текущая сеть должна быть добавлена в список разрешенных IP-адресов на шлюзе для обеспечения доступа к его сервисам.
3.	Включенные сервисы и порты:
HTTP API: Активирован для обеспечения возможности отправки и получения SMS через HTTP-интерфейс.
SSH: Включен для удаленного управления и настройки устройства. (по умолчанию порт 8022 логин:support пароль:iyeastar)
Asterisk Management Interface (AMI): 
Активирован для взаимодействия с функциями Asterisk на шлюзе.
Правильно указаны логин и пароль пользователя AMI для обеспечения авторизованного доступа.
## Программные требования:
1.	Установленный Docker:
o	Для обеспечения изоляции и упрощения развертывания компонентов системы необходимо установить Docker на сервере. 
2.	Signal Messenger REST API:
o	Для интеграции с Signal Messenger используется проект signal-cli-rest-api, предоставляющий REST API для взаимодействия с Signal.
Эти требования и шаги обеспечат корректную работу системы по приему и отправке SMS-сообщений через шлюзы Yeastar TG-Series с последующей пересылкой в Signal Messenger.
