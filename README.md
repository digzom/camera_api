# Camera API

## Como rodar este projeto

1. Instale o Docker e o Docker Compose na sua máquina.
2. Clone este repositório.
3. Do root do projeto, execute o seguinte comando:

   ```
   docker-compose up --build
   ```

   Este comando irá construir a imagem Docker, iniciar os contêineres, executar as migrações e popular o banco de dados automaticamente.

4. A aplicação estará disponível em `http://localhost:4000`.

## Endpoints da API

### 1. Listar Usuários com Câmeras Ativas

- **Endpoint**: GET `/api/cameras`
- **Descrição**: Busca uma lista de usuários e suas câmeras ativas.
- **Paginação**: Suporta paginação com os parâmetros `page` e `per_page`.
- **Filtragem**: Suporta filtragem por nome da câmera, marca da câmera e nome do usuário.
- **Ordenação**: Suporta ordenação por nome do usuário.

Exemplo de requisição:
```
GET /api/cameras?page=2&per_page=20&camera_brand=Hikvision&order=desc
```

### 2. Notificar Usuários com Câmeras Hikvision

- **Endpoint**: POST `/api/notify_users`
- **Descrição**: Envia uma notificação por e-mail para todos os usuários que têm câmeras Hikvision.

## Recursos

- Gerenciamento de usuários e câmeras com banco de dados PostgreSQL.
- Rápida população do banco de dados usando `Task.async`.
- Suporte à paginação.
- Capacidades de filtragem e ordenação.
- Notificações por e-mail para usuários com câmeras Hikvision.
- Aplicação dockerizada pronta para produção.

## Detalhes de Implementação

### Seeds

Optei por utilizar `Task.async` para popular o banco de dados com 1000 usuários e 50 câmeras por usuário. No benchmark feito através do módulo `CameraApi.SeederBenchmark`, com 20 mil usuários, a diferença foi de 34 segundos. A abordagem paralela durante 11 segundos e a síncrona um pouco mais de 45 segundos. Algo que poderia ser levemente melhorado é utilizar apenas metade dos schedulers online por padrão e ter a opção para utilizar todos caso queira.

### Paginação

O módulo `CameraApi.Pagination` faz uma diferença enorme na performance e no tamanho do payload the será enviado via http. O módulo implementado foi pensado para ser o mais genérico possível.

### Filtragem e Ordenação

A aplicação suporta filtragem por nome da câmera, marca da câmera e nome do usuário. A ordenação está disponível para nomes de usuários.

### Limitações e Potenciais Melhorias

1. **Filtragem e Ordenação em Nível de Banco de Dados**: 
    - Atualmente, algumas operações de filtragem e ordenação são realizadas em memória. Mover essas operações para o nível do banco de dados melhoraria o desempenho, especialmente para grandes conjuntos de dados.
    - Tentei adicionar filtragens dinâmicas utilizando a função `dynamic` Ecto e manipulando as strings dos filtros que deveriam seguir um padrão específico. Algo nesse sentido:
    ```elixir
      defp filter_by_query([[_, _column, "eq"]], query, schema, key, val) do
        where(query, ^eq(schema, key, val))
      end

      defp eq(nil, key, val), do: dynamic([m], field(m, ^key) == ^val)
      defp eq(schema, key, val), do: dynamic([{^schema, m}], field(m, ^key) == ^val)
    ```
    Acredito que seria possível criar filtros bastante genéricos com essa abordagem, mas tive muitos problemas para implementar isso e preferi priorizar outras partes do projeto.
2. **Busca Avançada**: implementar busca com `ilike`, até mesmo seguindo abordagem que sugeri acima, seria uma ótima adição para esse projeto.
3. **Autenticação de Usuário**: Não fazia parte do escopo desse teste, mas com certeza é uma feature essencial. Seria implementado com o Guardian, manipulando as requisições nos plugs e utilizando JWT como meio de autenticação.
4. **Documentação da API**: Gerar documentação com um swagger ajudaria muito.
5. **Validações**: Não consegui dar muita atenção aos erros que seriam retornados da API. Provavelmente essa é parte que eu mais queria ter feito durante o desenvolvimento.
    - Eu seguiria pelo caminho de criar respostas `json` padronizadas implementadas no módulo `CameraApiWeb.ErrorJSON`.
    - O padrão seria tentar retornar errors **somente** pelo `fallback_controller` de cada domínio (Account, Device, Houses, Workplaces...), de forma que o tratamento dos mesmos fosse centralizado.
6. **Filas para notificação**: num ambiente de produção provavelmente seria necessário utilizar filas para gerenciar as notificações tanto na questão do envio quanto no controle das notificações que falharam. Para isso eu utilizaria o Oban para que esses email também fossem enviados na execução de um background job.

## Desenvolvimento

Para fins de desenvolvimento, você pode acessar o seguinte:

- **Visualização de Caixa de Entrada**: Disponível em `/dev/mailbox` para visualizar e-mails enviados no desenvolvimento.
