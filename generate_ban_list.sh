#!/bin/bash

# Получение директории, где находится скрипт
script_dir="$(dirname "$(realpath "$0")")"

# Пути к входным и выходному файлам
input_dir="/home/fenix_vd/adguardhome-filters"
output_file="${script_dir}/ban_list.txt"

# Входные файлы
input_files=("admalware.txt" "fakenews.txt" "gambling.txt" "porn.txt" "social.txt")

# Создаем ассоциативный массив для хранения обновленных данных
declare -A updated_lines

# Чтение входных файлов и преобразование данных
for file in "${input_files[@]}"; do
    input_path="${input_dir}/${file}"
    if [[ -f "$input_path" ]]; then
        while IFS= read -r line; do
            # Удаление ^ на конце строки и замена || на 0.0.0.0
            transformed_line=$(echo "$line" | sed 's/^||/0.0.0.0 /;s/\^$//')
            # Добавление строки в массив
            updated_lines["$transformed_line"]=1
        done < "$input_path"
    else
        echo "Файл не найден: $input_path"
    fi
done

# Создаем массив для хранения текущих данных
declare -A current_lines

# Чтение существующего выходного файла
if [[ -f "$output_file" ]]; then
    while IFS= read -r line; do
        current_lines["$line"]=1
    done < "$output_file"
fi

# Удаление строк, отсутствующих в новых данных
for line in "${!current_lines[@]}"; do
    if [[ -z "${updated_lines[$line]}" ]]; then
        sed -i "/^$(echo "$line" | sed 's/[.[\*^$/]/\\&/g')$/d" "$output_file"
    fi
done

# Добавление новых строк, отсутствующих в существующих данных
for line in "${!updated_lines[@]}"; do
    if [[ -z "${current_lines[$line]}" ]]; then
        echo "$line" >> "$output_file"
    fi
done

echo "Список обновлен: $output_file"
