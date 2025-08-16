import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["starred", "read", "title", "description", "header"]

  connect() {
    console.log("Articles controller connected")
  }

  toggleStar(event) {
    const articleId = event.target.dataset.articleId
    const titleElement = event.target.closest('.article_item').querySelector('.article_item_title')

    fetch(`/articles/${articleId}/toggle_starred`, { 
      method: 'PATCH',
      headers: {  
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if(data.success) {
        this.updateStar(event.target, titleElement, data)  
      } else {
        console.log("Error toggling starred status: " + data.errors.join(', '))
      }
    })
    .catch(error => {  
      console.error('Error:', error)
    })
  }

  toggleRead(event) {
    const articleId = event.target.dataset.articleId
    const titleElement = event.target.closest('.article_item').querySelector('.article_item_title')

    fetch(`/articles/${articleId}/toggle_read`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.updateReadStatus(event.target, titleElement, data)
      } else {
        alert('Error toggling read status: ' + data.errors.join(', '))
      }
    })
    .catch(error => {
        console.error('Error:', error)
        alert('Network error occurred')
    })
  }

  showDescription(event) {
    const feedItem = event.target.closest('.article_item')
    const descriptionElement = feedItem.querySelector('.article_item_description')
    const readButton = feedItem.querySelector('.article_item_read')

    console.log('Current display:', descriptionElement.style.display)
    
    if (descriptionElement.style.display === 'none' || descriptionElement.style.display === '') {
      console.log('Setting to block')
      descriptionElement.style.display = 'block'

      if(readButton.dataset.read === 'false') {
        const articleId = readButton.dataset.articleId

        fetch(`/articles/${articleId}/toggle_read`, {
          method: 'PATCH',
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          }
        })
        .then(response => response.json())
        .then(data => {
          if(data.success) {
            this.updateReadStatus(readButton, event.target, data)
          } else {
            console.log('Error marking article as read: ' + data.errors.join(', '))
          }
        })
        .catch(error => { 
          console.error('Error:', error) 
        })
      }
    } else {
      descriptionElement.style.display = 'none'
    }
  }

  updateStar(toggleButton, titleElement, data) {
    console.log("Click! Starred Change State: " + data.starred)
    toggleButton.dataset.starred = data.starred
    toggleButton.innerHTML = data.starred ? '&#x2B50;' : '&#9734;'
  }

  updateReadStatus(toggleButton, titleElement, data) {
    toggleButton.dataset.read = data.read
    toggleButton.innerHTML = data.read ? '✓' : '◯'

    const itemHeaderElement = toggleButton.closest('.article_item_header')
    if (data.read) {
      titleElement.style.fontWeight = 'normal'
      itemHeaderElement.classList.remove('unread')
    } else {
      titleElement.style.fontWeight = 'bold'
      itemHeaderElement.classList.add('unread')
    }
  }
}