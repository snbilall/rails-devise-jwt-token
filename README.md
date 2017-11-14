
curl -H "Content-Type: application/json" -X POST -d '{"email":"a@b","password":"123456"}' http://localhost:3000/session_controller/create 

yukarıdaki istek kullanıcının id, email ve auth token niteliklerini döndürür
request written above returns user id, email and auth token

devise gemindeki auth token özelliği kaldırıldığı için simple_token gem kullanıldı
because of devise's auth token ability deprecated, simple_token gem has been used.

Update: simple_comand => jwt