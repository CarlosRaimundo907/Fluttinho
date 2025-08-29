# Fluttinho

`By Luferat: atualizado em 29/08/2025`

Aplicativo experimental com Flutter. Um CRUD simples usando uma API REST.

## Instalando

 - Baixe o aplicativo
 - Abra na sua IDE
   - Recomendo o Android Studio
 - Baixe as dependências
   - Abra um terminal e comande `flutter pub get`
 
Se precisar usar a **API Fake** embitida, siga os passos: 

> Para que a API Fake funcione é necessário ter o Node.js atualizado no sistema.

 - Abra um terminal e acesse o diretório da API comandando `cd apifake`
 - Baixe as dependências comandando `npm install`
 - Rode a API comandando `npx json-server db.json -p 8080`

> Para mais detalhes sobre a API Fake, acesse https://gist.lufer.click/linguagens-e-plataformas/javascript/api-fake

## Rodando

- Versão Web
  - Selecione a plataforma "Web" e rode a _lib_ `main.dart`
- Versão Android
  - Conecte um celular no modo desenvolvedor ou um emulador
  - Selecione o celular ou a plataforma correta e rode a _lib_ `main.dart`

_EOF_