/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './*.html',
    './xtech/**/*.html',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          black: '#050505',
          dark: '#111111',
          surface: '#1E1E1E',
          border: '#333333',
          red: '#D32F2F',
          gold: '#D4AF37',
          text: '#F3F4F6',
          muted: '#9CA3AF',
        }
      },
      fontFamily: {
        sans: ['"EB Garamond"', 'Garamond', 'serif'],
      }
    }
  }
}
