# The Set Helsinki Enterprise

Versión limpia para crear el proyecto desde cero en GitHub y Vercel.

Usa la misma Supabase:

```text
https://yiumnpzvbfkwgnfcrots.supabase.co
```

## Ventaja principal

Esta versión no usa Vite, React ni `/src/main.jsx`. Es una aplicación estática, por lo que Vercel no necesita compilarla.

## Estructura

```text
index.html
app.js
styles.css
config.js
vercel.json
supabase/
  schema.sql
  functions/admin-users/index.ts
```

## 1. GitHub

Crea un repositorio nuevo y vacío.

Descomprime el ZIP y sube todos los archivos y la carpeta `supabase`. No subas el ZIP.

## 2. config.js

En Supabase abre:

```text
Settings → API Keys → Publishable key
```

Copia la Publishable Key y reemplaza:

```text
sb_publishable_dQfZ_HYELluPoAH34kbXrQ_gWRlTJMg
```

Cambia también `APP_URL` por el dominio real de Vercel.

Nunca pongas la Secret Key o Service Role Key en `config.js`.

## 3. Vercel desde cero

Importa el repositorio nuevo y selecciona:

```text
Framework Preset: Other
Build Command: vacío
Output Directory: vacío
Install Command: vacío
Root Directory: ./
```

## 4. Base de datos

Ejecuta `supabase/schema.sql` en Supabase SQL Editor.

## 5. Recuperación de contraseña

En Supabase → Authentication → URL Configuration:

```text
Site URL:
https://TU-DOMINIO.vercel.app

Redirect URLs:
https://TU-DOMINIO.vercel.app/reset-password
```

## 6. Crear usuarios desde la app

Despliega `supabase/functions/admin-users/index.ts`:

```bash
supabase login
supabase link --project-ref yiumnpzvbfkwgnfcrots
supabase functions deploy admin-users
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=TU_SERVICE_ROLE_KEY
```

## Incluye

- Login y recuperación de contraseña.
- Español, English y Suomi.
- Super Admin, Admin, Manager y Employee.
- Creación de usuarios mediante Edge Function.
- Restaurantes y empleados.
- Asignación a múltiples restaurantes.
- Rota de tres semanas.
- Drag & drop.
- Colores y notas.
- Payroll base estimado.
- VV básico.
- Impresión A4 horizontal.

## Importante

El Payroll mostrado es una base estimada. Antes de utilizarlo para nómina oficial deben añadirse y validarse las reglas TES vigentes: evening, night, Sunday, holiday, aatto y overtime.
