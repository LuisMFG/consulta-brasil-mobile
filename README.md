# Consulta Brasil

Portal de Transparência do Governo Federal - Aplicativo Flutter para consulta de dados públicos brasileiros.

## 📱 Sobre o App

O **Consulta Brasil** é um aplicativo mobile que facilita o acesso aos dados públicos do Governo Federal brasileiro. Desenvolvido em Flutter, oferece uma interface moderna e intuitiva para visualizar informações de transparência governamental.

## 🔗 APIs Utilizadas

O aplicativo integra com as seguintes APIs oficiais do governo brasileiro:

### Portal da Transparência
- **URL**: `https://api.portaldatransparencia.gov.br/api-de-dados`
- **Dados**: Gastos diretos, receitas públicas, transferências
- **Documentação**: [Portal da Transparência](https://portaldatransparencia.gov.br/api-de-dados)

### SICONV - Sistema de Gestão de Convênios
- **URL**: `https://api.convenios.gov.br/siconv/v1`
- **Dados**: Convênios e contratos de repasse
- **Documentação**: [SICONV API](https://api.convenios.gov.br/siconv/doc)

### DataSUS - Dados Abertos da Saúde
- **URL**: `https://apidadosabertos.saude.gov.br`
- **Dados**: Estabelecimentos de saúde, CNES
- **Documentação**: [DataSUS](https://datasus.saude.gov.br/)

### IBGE - Instituto Brasileiro de Geografia e Estatística
- **URL**: `https://servicodados.ibge.gov.br/api/v1`
- **Dados**: Localidades, municípios, estados
- **Documentação**: [IBGE API](https://servicodados.ibge.gov.br/api/docs)

### Banco Central do Brasil
- **URL**: `https://api.bcb.gov.br`
- **Dados**: Taxas de juros, indicadores econômicos
- **Documentação**: [BCB API](https://dadosabertos.bcb.gov.br/)

### Tesouro Transparente
- **URL**: `https://www.tesourotransparente.gov.br/ckan/api/3/action`
- **Dados**: Títulos públicos, dívida pública
- **Documentação**: [Tesouro Transparente](https://www.tesourotransparente.gov.br/)

## 🚀 Funcionalidades

### 🏠 Tela Inicial
- Notícias geradas automaticamente a partir dos dados das APIs
- Estatísticas resumidas dos gastos públicos
- Interface responsiva e atrativa

### 📊 Gastos Públicos
- Gráficos de pizza e barras interativos
- Filtros por ano (2023, 2024, 2025)
- Dados reais do Portal da Transparência
- Visualização por setores (Saúde, Educação, Previdência, etc.)

### ⭐ Avaliação do App
- Sistema de avaliação de 1 a 5 estrelas
- Critérios: velocidade, usabilidade, acessibilidade, segurança
- Requer login para envio de avaliações
- Persistência local com SharedPreferences

### ⚙️ Configurações
- Tema claro/escuro
- Gerenciamento de conta
- Informações sobre o app

## 🛠️ Tecnologias

- **Flutter 3.10+**
- **Dart 3.0+**
- **Provider** - Gerenciamento de estado
- **fl_chart** - Gráficos interativos
- **http** - Requisições HTTP
- **shared_preferences** - Persistência local
- **cached_network_image** - Cache de imagens
- **google_fonts** - Fontes personalizadas

## 📋 Pré-requisitos

- Flutter SDK 3.10.0 ou superior
- Dart SDK 3.0.0 ou superior
- Android Studio / VS Code
- Dispositivo Android ou emulador

## 🔧 Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/consulta-brasil.git
cd consulta-brasil
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure as APIs**
   - Algumas APIs podem requerer chaves de acesso
   - Edite o arquivo `lib/services/api_service.dart` se necessário

4. **Execute o app**
```bash
flutter run
```

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request
