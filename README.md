# EQStudio Affiliate Dashboard

A full-featured affiliate dashboard system built with pure HTML/CSS/JS and Supabase.

## 📁 Project Structure

```
eqstudio-affiliate/
├── index.html              ← Login page (entry point)
├── pages/
│   ├── admin.html          ← Admin panel
│   └── affiliator.html     ← Affiliator portal
├── css/
│   └── style.css           ← Full design system
├── js/
│   ├── config.js           ← Supabase credentials (edit this!)
│   └── utils.js            ← Shared utilities
└── SUPABASE_SCHEMA.sql     ← Run this in Supabase SQL editor
```

---

## 🚀 Setup Guide

### Step 1 — Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your **Project URL** and **anon public key** from Settings → API

### Step 2 — Configure your credentials

Edit `js/config.js`:
```js
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
const ADMIN_EMAIL = 'admin@yourdomain.com'; // Your admin email
```

### Step 3 — Set up the database

1. In your Supabase dashboard, go to **SQL Editor**
2. Paste the contents of `SUPABASE_SCHEMA.sql` and click **Run**
3. This creates all tables, RLS policies, and triggers

### Step 4 — Create the admin account

1. In Supabase, go to **Authentication → Users**
2. Click **Invite user** or **Add user**
3. Create a user with the same email you set as `ADMIN_EMAIL` in config.js
4. Set a strong password

### Step 5 — Deploy to GitHub Pages

1. Push this entire folder to a GitHub repository
2. Go to **Settings → Pages** in your repo
3. Set source to `main` branch, `/ (root)` folder
4. Your site will be live at `https://yourusername.github.io/repo-name/`

---

## 👤 Admin Features

| Feature | How to access |
|---|---|
| Add affiliator | Affiliators tab → Add Affiliator button |
| Update promo code uses | Edit button (pencil icon) on any affiliator row |
| Update commission total | Edit button → Commission field |
| Log a commission payment | Dollar icon on affiliator row |
| View commission history | Checkmark icon on affiliator row |
| Deactivate affiliator | Edit → Status → Inactive |
| Delete affiliator | Trash icon on affiliator row |
| Post announcement | Announcements tab → New Announcement |
| Pin announcement | Star icon on any announcement |
| Export to CSV | Filter bar → Export CSV button |

---

## 🎯 Affiliator Features

| Feature | How to access |
|---|---|
| Copy promo code | Dashboard → copy button |
| See code uses | Dashboard stats |
| See commission total | Dashboard stats |
| See commission history | Commissions tab |
| Update contact info | My Profile tab |
| Change password | My Profile tab |
| Read announcements | Announcements tab |

---

## 🔒 Security Notes

- **RLS is enabled** on all tables — affiliators can only read their own data
- The admin check uses email matching (`is_admin()` function in Supabase)
- Change `ADMIN_EMAIL` in `config.js` to match your actual admin email
- The anon key is safe to expose in frontend code (it's designed for this)
- For production, consider adding email verification for new affiliator signups

---

## 🎨 Design System

| Token | Value |
|---|---|
| Background | `#0a0a0a` |
| Surface | `#111111` |
| Elevated | `#161616` |
| Gold accent | `#c9a84c` |
| Gold bright | `#e2b84a` |
| Green (positive) | `#4caf7d` |
| Red (danger) | `#e05c5c` |
| Font display | Syne 700/800 |
| Font body | Inter 400/500/600 |

---

## 📝 Customization

- **Currency**: Change `'RM '` in `utils.js` → `formatCurrency()` to your currency
- **Demo link**: Update `APP_CONFIG.demoLink` in `config.js`
- **Brand name**: Update "EQStudio" references in HTML files
- **Accent color**: Change `--gold` and `--gold-bright` in `css/style.css`
