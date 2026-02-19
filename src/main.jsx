import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import Card from './component/card.jsx'
import Createtodo from './component/Createtodo.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <Createtodo />
  </StrictMode>,
)
