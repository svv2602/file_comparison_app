# Используем образ Ruby версии 3.0
FROM ruby:3.1.3

# Устанавливаем зависимости для приложения Rails
RUN apt-get update -qq && apt-get install -y nodejs
RUN  apt install -y tesseract-ocr libtesseract-dev poppler-utils
# Устанавливаем переменную окружения для задания кодировки UTF-8
ENV LANG C.UTF-8

# Устанавливаем директорию, где будет располагаться приложение Rails
WORKDIR /app

# Копируем файлы Gemfile и Gemfile.lock в контейнер
COPY Gemfile Gemfile.lock ./

# Устанавливаем зависимости приложения Rails
RUN bundle install

# Копируем остальные файлы проекта в контейнер
COPY . .

# Выполняем миграции базы данных
RUN rails db:migrate

# Запускаем сервер приложения на порту 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
