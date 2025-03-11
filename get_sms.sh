#!/bin/bash

# Параметры подключения к AMI
AMI_HOST="172.16.3.30"
AMI_PORT=5038
AMI_USER="apiuser"
AMI_PASS="apipass"

# Директория для сохранения SMS
SMS_DIR="/tmp/sms"

# Создаем директорию, если она не существует
mkdir -p "$SMS_DIR"

# Функция для подключения к AMI и получения событий
get_sms() {
    # Подключаемся к AMI и отправляем команды
    {
        echo "Action: Login"
        echo "Username: $AMI_USER"
        echo "Secret: $AMI_PASS"
        echo ""
        echo "Action: Events"
        echo "EventMask: on"
        echo ""
    } | nc $AMI_HOST $AMI_PORT | while read -r line; do
        echo "Received: $line" | tee -a /tmp/ami_events.log  # Логируем события
        if [[ "$line" =~ ^Event:\ ReceivedSMS ]]; then
            declare -A sms
            while read -r line; do
                echo "Processing: $line" | tee -a /tmp/ami_events.log  # Логируем обработку
                if [[ "$line" =~ ^--END\ SMS\ EVENT-- ]]; then
                    break
                fi
                if [[ "$line" =~ ^([^:]+):\ (.*) ]]; then
                    key="${BASH_REMATCH[1]}"
                    value="${BASH_REMATCH[2]}"
                    sms["$key"]="$value"
                fi
            done

            # Формируем имя файла
            filename="${sms[Recvtime]//[: ]/-}_${sms[Sender]}.txt"
            # Полный путь к файлу
            full_path="$SMS_DIR/$filename"
            # Записываем содержимое SMS в файл
            echo "ID: ${sms[ID]}" > "$full_path"
            echo "GsmPort: ${sms[GsmPort]}" >> "$full_path"
            echo "Sender: ${sms[Sender]}" >> "$full_path"
            echo "Recvtime: ${sms[Recvtime]}" >> "$full_path"
            echo "Index: ${sms[Index]}" >> "$full_path"
            echo "Total: ${sms[Total]}" >> "$full_path"
            echo "Smsc: ${sms[Smsc]}" >> "$full_path"
            echo "Content: ${sms[Content]}" >> "$full_path"
            echo "SMS saved to $full_path"
        fi
    done
}

# Вызов функции получения SMS
get_sms