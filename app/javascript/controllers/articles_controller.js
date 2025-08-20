import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["starred", "read", "title", "description", "header"]

  // Tell me you're working, please?
  connect() {
    console.log("Articles controller connected")
  }

  toggleStar(event) {
    const articleId = event.target.dataset.articleId

    // There may be a better way to do this, I should revist this when I can...
    const titleElement = event.target.closest('.article_item').querySelector('.article_item_title')

    this.makeRequest(`/articles/${articleId}/toggle_starred`)
      .then(data => {
        if (data.success) {
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

    this.makeRequest(`/articles/${articleId}/toggle_read`)
      .then(data => {
        if (data.success) {
          this.updateReadStatus(event.target, titleElement, data);
        } else {
          alert('Error toggling read status: ' + data.errors.join(', '));
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('Network error occurred');
      })
  }

  // Click on title to show/hide the article preview
  showDescription(event) {
    const feedItem = event.target.closest('.article_item')
    const descriptionElement = feedItem.querySelector('.article_item_description')

    // Get the Read Button so it can be changed as well
    const readButton = feedItem.querySelector('.article_item_read')

    // Hide all other descriptions before opening this one
    this.closeAllExcept(descriptionElement)

    if (descriptionElement.style.display === 'none' || descriptionElement.style.display === '') {
      descriptionElement.style.display = 'block'

      // Auto-mark as read when someone actually opens it to read
      if (readButton.dataset.read === 'false') {
        const articleId = readButton.dataset.articleId
        this.makeRequest(`/articles/${articleId}/toggle_read`)
          .then(data => {
            if (data.success) {
              this.updateReadStatus(readButton, event.target, data)
            } else {
              console.log('Error marking article as read: ' + data.errors.join(', '))
            }
          })
      }
    } else {
      // Hide the article contents if clicked again
      descriptionElement.style.display = 'none'
    }
  }

  // Helper to close all descriptions except the current one
  closeAllExcept(currentElement) {
    document.querySelectorAll('.article_item_description').forEach(el => {
      if (el !== currentElement) {
        el.style.display = 'none'
      }
    })
  }


  // No more fetch code everywhere! It has it's own place! 
  async makeRequest(url) {
    const response = await fetch(url, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    return await response.json()
  }


  // Update the star icon - filled vs empty
  updateStar(toggleButton, titleElement, data) {
    console.log("Updating star status to: " + data.starred)
    toggleButton.dataset.starred = data.starred
    // HTML entities for star icons (⭐ vs ☆)
    toggleButton.innerHTML = data.starred ? '&#x2B50;' : '&#9734;'
  }

  // Update read button icon and make title bold/normal
  updateReadStatus(toggleButton, titleElement, data) {
    console.log("Updating read status to: " + data.read)
    toggleButton.dataset.read = data.read
    toggleButton.innerHTML = data.read ? '✓' : '◯'

    const itemHeaderElement = toggleButton.closest('.article_item_header')

    if (data.read) {
      // Read articles look normal
      titleElement.style.fontWeight = 'normal'
      itemHeaderElement.classList.remove('unread')
    } else {
      // Unread articles are bold and get pretty blue highlighting background
      titleElement.style.fontWeight = 'bold'
      itemHeaderElement.classList.add('unread')
    }
  }
}