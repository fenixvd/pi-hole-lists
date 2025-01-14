#!/bin/bash

# Получение директории, где находится скрипт
script_dir="$(dirname "$(realpath "$0")")"

# Пути к входным и выходному файлам
input_dir="/home/fenix_vd/adguardhome-filters"
output_file="${script_dir}/ban_list.txt"

# Входные файлы
input_files=("admalware.txt" "fakenews.txt" "gambling.txt" "porn.txt" "social.txt")

# Очистка выходного файла, если он уже существует
> "$output_file"

# Обработка файлов
for file in "${input_files[@]}"; do
    input_path="${input_dir}/${file}"
    if [[ -f "$input_path" ]]; then
        while IFS= read -r line; do
            # Удаление ^ на конце строки и замена || на 0.0.0.0
            transformed_line=$(echo "$line" | sed 's/^||/0.0.0.0 /;s/\^$//')
            # Запись в выходной файл
            echo "$transformed_line" >> "$output_file"
        done < "$input_path"
    else
        echo "Файл не найден: $input_path"
    fi
done

echo "Список создан: $output_file"
