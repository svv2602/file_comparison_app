### README
* Для работы приложения необходима установка
  *  apt install -y tesseract-ocr libtesseract-dev poppler-utils

* Создать пользователя с правами админ в консоле
```
$ rails c
 
User.create!(email:'admin@example.com',
            password:"password",
            password_confirmation:"password", 
            role:"admin")
``` 
* Добавить правила для обработки распознаного текста можно в lib/servis_pdf/text_processing.rb (метод process_text_content)