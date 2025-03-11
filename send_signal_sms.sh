#!/bin/bash

# Параметры Signal API
SIGNAL_API_URL="http://localhost:8080/v2/send"  # URL Signal API
SIGNAL_NUMBER="+380XXXXXXXXXX"                       # Номер, используемый для отправки

# Директория для чтения SMS-сообщений
SMS_DIR="/tmp/sms"

# Создаем директорию, если она не существует
mkdir -p "$SMS_DIR"

# Основной цикл
while true; do
    # Перебираем все файлы в директории
    for sms_file in "$SMS_DIR"/*.txt; do
        # Проверяем, существует ли файл (на случай, если файлов нет)
        if [[ -f "$sms_file" ]]; then
            # Удаляем символы \r из имени файла
            sms_file_clean=$(echo "$sms_file" | tr -d '\r')

            # Читаем содержимое файла и удаляем символы \r
            SMS_CONTENT=$(<"$sms_file" tr -d '\r')

            # Проверяем, не пустое ли содержимое
            if [[ -n "$SMS_CONTENT" ]]; then
                echo "Обработка файла: $sms_file"
                echo "Содержимое: $SMS_CONTENT"

                # Извлекаем отправителя (Sender) и текст SMS (Content)
                SENDER=$(echo "$SMS_CONTENT" | grep -oP 'Sender: \K\+[0-9]+')
                CONTENT=$(echo "$SMS_CONTENT" | grep -oP 'Content: \K.*')

                # Проверяем, удалось ли извлечь данные
                if [[ -n "$SENDER" && -n "$CONTENT" ]]; then
                    echo "Отправитель: $SENDER"
                    echo "Текст SMS: $CONTENT"

                    # Добавляем номер отправителя в тело сообщения
                    FULL_MESSAGE="Отправитель: $SENDER\n$CONTENT"

                    # Формируем JSON-запрос
                    JSON_DATA=$(cat <<EOF
{
    "message": "$FULL_MESSAGE",
    "number": "$SIGNAL_NUMBER",
    "recipients": ["$SENDER"]
}
EOF
                    )

                    # Логируем JSON-запрос для отладки
                    echo "Отправляемый JSON: $JSON_DATA"

                    # Отправляем сообщение через Signal API
                    RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" "$SIGNAL_API_URL" -d "$JSON_DATA")

                    # Проверяем результат
                    if [[ $? -eq 0 ]]; then
                        echo "Сообщение успешно отправлено."
                        echo "Ответ сервера: $RESPONSE"
                        # Удаляем файл после успешной отправки (если он существует)
                        if [[ -f "$sms_file" ]]; then
                            rm -f "$sms_file"
                            echo "Файл удален: $sms_file"
                        else
                            echo "Файл уже удален или отсутствует: $sms_file"
                        fi
                    else
                        echo "Ошибка при отправке сообщения."
                        echo "Ответ сервера: $RESPONSE"
                    fi
                else
                    echo "Не удалось извлечь отправителя или текст SMS."
                fi
            else
                echo "Файл пуст, удаляем: $sms_file"
                if [[ -f "$sms_file" ]]; then
                    rm -f "$sms_file"
                    echo "Файл удален: $sms_file"
                else
                    echo "Файл уже удален или отсутствует: $sms_file"
                fi
            fi
        fi
    done

    # Ожидание перед следующим запуском
    sleep 10
done
