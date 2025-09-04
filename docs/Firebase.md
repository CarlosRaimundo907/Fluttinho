# Integração com Firebase

Para que o sistema de autenticação de usuários usando o Google (_Login Social_) funcione adequadamente, é necessário criar um novo projeto no [Firebase](https://firebase.com) e conectá-lo ao App Flutter.
Siga os procedimentos abaixo com atenção!

> _Firebase é um serviço de back-end completo para aplicações Web e mobile, mantido pelo Google.
> O serviço "Authentication" que estamos usando faz parte da sessão gratuita (Plano Spark) da ferramenta._

## Criando um Projeto Firebase

 - [ ] Acesse o site do Firebase - https://firebase.com - e logue-se com sua conta Google;
 - [ ] Acesse o **Console do Firebase** clicando em "Ir para o console";
 - [ ] Clique em "Criar um novo projeto do Firebase";
 - [ ] Dê um nome para o projeto, por exemplo, `Flutinho`;
 - [ ] Desmarque "Ativar o Gemini no Firebase" e clique em `[Continuar]`;
 - [ ] Desmarque "Ativar o google Analytics" e clique em `[Continuar]`;
 - [ ] Aguarde a criação do projeto e clique em `[Continuar]`;

## Criado um Aplicativo no Projeto

###  Aplicativo Flutter

Os dados do aplicativo Flutter serão usados em tempo de desenvolvimento.

- [ ] No console do projeto, clique em `[+ Adicionar app]` logo abaixo do nome do projeto;
- [ ] Ao pedir para selecionar uma plataforma, clique em "Flutter";
> _Neste momento são exibidos passos para preparar o ambiente, mas faremos isso depois!_
- [ ] Clique nos botões `[Avançar]` que aparecem e finalmente em `[Continuar no console]`;

### Aplicativo Web

Este aplicativo permite que a versão Web do nosso aplicativo Flutter se conecte ao Firebase em tempo de execução.

- [ ] No console, clique em `[+ Adicionar app]` novamente e selecione "Web";
- [ ] Dê um apelido para este app, por exemplo, "fluttinhoweb", somente minúsculas e "_";
- [ ] Clique em `[Registrar app]` depois em `[Continuar no console]`;

### Aplicativo Android

Da mesma forma, este aplicativo conecta nosso app Flutter na versão Web ao Firebase em tempo de execução.

- [ ] No console, clique em `[+ Adicionar app]` novamente e selecione "Android";
- [ ] Dê um nome para o pacote, por exemplo "net.luferat.fluttinho";
- [ ] Crie um apelido para o aplicativo, por exemplo "fluttinhoandroid";
- [ ] Clique em "Registrar App";
- [ ] Faça download do "google-services.json" e clique em `[Avançar]`;
- [ ] No aplicativo, salve este "google-services.json" no diretório `android/app`;
- [ ] Ignore as instruções para adicionar o SDK, por enquanto, e clique em `[Avançar]`;
- [ ] Finalmente, clique em `[Continuar no console]`;

## Gerando um `firebase_options.dart`

Toda a conexão entre o aplicativo Flutter e o aplicativo Firebase é feita a partir do arquivo `firebase_options.dart` que está no mesmo nível da sua lib `main` (`main.dart`).

Para gerar este arquivo novamente com as suas próprias credenciais Firebase, faça o seguinte:

Caso o aplicativo Flutter esteja rodando, encerre-o! Também é necessário ter o **Node.js** instalado e atualizado no sistema.

Abra um **Command Prompt** do Windows e instale a CLI (_Command Line Interface_) do Firebase com o comando:
```cmd
npm install -g firebase-tools
```

Teste a instalação comandando:
```cmd
firebase --version
```

Se der erro como:
```cmd
'firebase' não é reconhecido como um comando interno
ou externo, um programa operável ou um arquivo em lotes.
```

Adicione o caminho `%USERPROFILE%\AppData\Roaming\npm` ao `Path` nas variáveis de ambiente.
Feche o prompt e abra novamente para que este leia as variáveis de ambiente.

Instale também a CLI do FlutterFire com o comando:
```cmd
dart pub global activate flutterfire_cli
```

Acesse a pasta do aplicativo pelo prompt ou então, reinicie o Android Studio e abra um terminal CMD por ele.

Autentique-se no Firebase com o comando:
```cmd
firebase login
```

Configure o Firebase no app flutter com o comando:
```cmd
flutterfire configure
```
Esse comando vai:
 - Listar seus projetos Firebase
 - Permitir escolher os apps Android/Web registrados
 - Gerar o arquivo `lib/firebase_options.dart`

Reinicie o aplicativo Flutter, verificando o log em busca de mensagens de erro...

_EOF_
