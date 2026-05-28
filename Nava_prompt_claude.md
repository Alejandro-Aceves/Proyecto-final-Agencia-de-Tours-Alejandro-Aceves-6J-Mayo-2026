¡Vamos! Sigue estos pasos:

## 1. Instalar Firebase Tools

```bash
npm install -g firebase-tools
```

Si te da error de permisos en Fedora:
```bash
sudo npm install -g firebase-tools
```

---

## 2. Iniciar sesión en Firebase

```bash
firebase login
```

Esto abrirá el navegador para autenticarte con tu cuenta de Google. Acepta los permisos y regresa a la terminal.

---

## 3. Compilar la app para web

```bash
cd ~/Downloads/lifetours_project/lifetours
flutter build web --release
```

Esto genera la carpeta `build/web/` con todos los archivos listos.

---

## 4. Inicializar Firebase Hosting

```bash
firebase init hosting
```

Te hará preguntas, responde así:

```
Which Firebase project? → bdtourscrud

What do you want to use as your public directory? → build/web

Configure as single-page app? → y

Set up automatic builds with GitHub? → n

File build/web/index.html already exists. Overwrite? → n
```

---

## 5. Desplegar

```bash
firebase deploy
```

Al finalizar verás algo así:
```
✅ Deploy complete!
Hosting URL: https://bdtourscrud.web.app
```

Esa URL la abres desde tu iPhone en Safari y funciona como una web app. 🚀

Comparte lo que aparece en cada paso y te ayudo si surge algo.
