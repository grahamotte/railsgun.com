import Nav from '../components/nav'
import React from 'react'
import ReactDOM from 'react-dom'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Nav />,
    document.body.appendChild(document.createElement('div')),
  )
})
