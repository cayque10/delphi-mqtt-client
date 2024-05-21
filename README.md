# Componente de Conexão MQTT (Client)

Componente de conexão MQTT (Client) utilizado para efetuar a comunicação com o serviço de mensageria MQTT.

Esse componente é a junção de dois componentes MQTT. Devido a certos problemas em ambos os componentes, decidi juntar os códigos e gerar um novo componente MQTT utilizando a base de cada um.

## Correções e ajustes realizados

- Efetuado a remoção de units vinculadas a plataforma Windows, abrindo o caminho para uso em multiplataforma (FMX)
- Efetuado correções relacionadas ao uso no Android
- Correções de violações de acesso e vazamento de memória

## Bibliotecas

Esse projeto utiliza como base o componente Indy para efetuar a comunicação, portanto são utilizadas algumas bibliotecas.

- Windows - Versão 1.0.2u
  - libeay32.dll
  - ssleay32.dll
- Android - 1.0.2s-flips 28 Maio de 2019
  - armeabi-v7a
    - libcrypto.so
    - libssl.so
  - arm64-v8a
    - libcrypto.so
    - libssl.so

Um agradecimento ao DelphiUdIT por compartilhar as bibliotecas do Android: https://en.delphipraxis.net/topic/8485-openssl-fails-to-load/

## Testes

Foram efetuados testes básicos somente no Windows (32 bits) e no Android (32 bits e 64 bits) em ambiente de desenvolvimento.

## Trabalho em andamento

O componente ainda está numa versão alfa e precisa passar por mais testes e melhorias.

## Contribuições

Caso queiram contribuir com o desenvolvimento do projeto, são bem-vindos.

## Créditos

Os códigos utilizados foram baseados nos códigos escritos por outros desenvolvedores. Eu apenas juntei alguns códigos para que funcionasse conforme o esperado.

#### Autor: pjde

GitHub do fonte do componente utilizado: https://github.com/pjde/delphi-mqtt

#### Autor: wizinfantry

GitHub do fonte do componente utilizado: https://github.com/wizinfantry/delphi-mqtt-client/tree/master
