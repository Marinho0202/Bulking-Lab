# Bulking Lab 🏋️

App de nutrição gamificada com ranking entre amigos, desenvolvido em Flutter/Dart.

---

## 📁 Estrutura do projeto

```
bulking_lab/
├── lib/
│   ├── main.dart                    # Entry point, tema e providers
│   ├── data/
│   │   └── food_database.dart       # Banco de alimentos estático (40+ alimentos BR)
│   ├── models/
│   │   ├── user_model.dart          # Usuário + cálculo TMB, TDEE, metas
│   │   ├── meal_model.dart          # FoodItem, MealEntry, DailyLog
│   │   └── group_model.dart         # Grupos e membros
│   ├── services/
│   │   ├── auth_service.dart        # Login/registro com SharedPreferences
│   │   ├── meal_service.dart        # CRUD de refeições
│   │   ├── group_service.dart       # Criação e gestão de grupos
│   │   └── scoring_service.dart     # Lógica de pontuação (0–100 pts)
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart     # Onboarding em 3 passos
│   │   ├── home_screen.dart         # Dashboard principal
│   │   ├── register_meal_screen.dart
│   │   ├── history_screen.dart      # Histórico com swipe-to-delete
│   │   ├── ranking_screen.dart      # Pódio + ranking por grupo
│   │   ├── stats_screen.dart        # Gráficos e estatísticas
│   │   └── groups_screen.dart       # Criar/entrar em grupos
│   ├── utils/
│   │   └── constants.dart           # Cores, textos, espaçamentos
│   └── widgets/
│       └── common_widgets.dart      # Componentes reutilizáveis
├── pubspec.yaml
└── README.md
```

---

## ⚙️ Pré-requisitos

- **Flutter SDK** 3.x → https://docs.flutter.dev/get-started/install
- **Dart SDK** (incluído no Flutter)
- **Android Studio** ou **VS Code** com extensão Flutter
- **JDK 17** (para build Android)
- **Git** instalado

Verifique se está tudo ok:
```bash
flutter doctor
```

---

## 🚀 Configuração inicial

### 1. Clone o repositório

```bash
git clone https://github.com/SEU_USUARIO/Bulking-Lab.git
cd Bulking-Lab
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Rode no emulador (teste rápido)

```bash
flutter run
```

---

## 📱 Como instalar no celular via Cabo USB-C

### Passo 1 — Habilitar o Modo Desenvolvedor no Android

1. Abra **Configurações** no celular
2. Vá em **Sobre o telefone**
3. Toque **7 vezes** em **Número da versão** (ou Build number)
4. Uma mensagem aparecerá: *"Você agora é um desenvolvedor!"*

### Passo 2 — Ativar a Depuração USB

1. Volte em **Configurações**
2. Vá em **Opções do desenvolvedor** (geralmente em Configurações Adicionais ou Sistema)
3. Ative **Depuração USB** (USB Debugging)

### Passo 3 — Conectar o cabo e verificar

```bash
# Conecte o celular via cabo USB-C ao computador
# No celular, toque em "Permitir" quando perguntar sobre depuração USB

# Verifique se o dispositivo foi reconhecido:
flutter devices
```

Você verá algo como:
```
SM-G991B (mobile) • R5CR905FZXX • android-arm64 • Android 13 (API 33)
```

### Passo 4 — Instalar o app em modo debug (rápido)

```bash
flutter run
```

O app será compilado e instalado automaticamente no celular conectado.

### Passo 5 — Gerar APK de release (para distribuir)

```bash
# Gera o APK otimizado
flutter build apk --release

# O arquivo ficará em:
# build/app/outputs/flutter-apk/app-release.apk
```

Para instalar o APK gerado diretamente:
```bash
flutter install
```

Ou copie o arquivo `app-release.apk` para o celular e abra pelo gerenciador de arquivos.

---

## 🎮 Funcionalidades do MVP

| Tela | Status |
|------|--------|
| Splash com animação | ✅ |
| Login com e-mail/senha | ✅ |
| Cadastro em 3 etapas | ✅ |
| Dashboard com pontuação diária | ✅ |
| Registro de refeição (40+ alimentos) | ✅ |
| Histórico com swipe-to-delete | ✅ |
| Ranking semanal por grupo | ✅ |
| Gráficos de desempenho | ✅ |
| Criar/entrar em grupos | ✅ |
| Sistema de pontuação 0–100 pts | ✅ |
| Bônus por constância e metas | ✅ |
| Persistência local (SharedPreferences) | ✅ |

---

## 🧮 Lógica de pontuação

- **60% adequação calórica** — compara ingestão vs meta individual (TMB × fator de atividade ± objetivo)
- **40% distribuição de macros** — proteína (50%), carbos (30%), gordura (20%)
- **Bônus semanal**: +15 pts por ≥5 dias ativos | +20 pts por atingir meta semanal
- Micronutrientes: exibidos como info, não pontuam

---

## 📦 Dependências

| Pacote | Uso |
|--------|-----|
| `provider` | Gerenciamento de estado |
| `shared_preferences` | Persistência local |
| `fl_chart` | Gráficos de barras e linhas |
| `google_fonts` | Fontes Syne + DM Sans |
| `uuid` | IDs únicos |
| `intl` | Formatação de datas |

---

## 🛠️ Comandos úteis

```bash
flutter pub get          # Instalar dependências
flutter run              # Rodar em dispositivo/emulador
flutter build apk        # Gerar APK debug
flutter build apk --release  # Gerar APK release
flutter clean            # Limpar cache de build
flutter analyze          # Análise estática do código
```

---

## 💡 Dicas

- Se `flutter doctor` mostrar erros de Android SDK, abra o Android Studio e instale os SDKs sugeridos
- Para builds mais rápidos: `flutter run --debug`
- Para testar sem dispositivo físico: `flutter emulators --launch <nome>`
- O app usa **tema escuro** por padrão, otimizado para AMOLED

---

*Desenvolvido como projeto acadêmico — Bulking Lab © 2025*
