  // Function to check if dark mode is preferred by the user
  function prefersDarkMode() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }

  // Dark mode toggle logic
  const darkModeToggle = document.getElementById('darkModeToggle');
  const htmlElement = document.documentElement;

  // Check if dark mode is preferred by the user's system
  const prefersDark = prefersDarkMode();

  // Apply dark mode based on user choice from local storage or system preference
  const isDarkMode = localStorage.getItem('darkMode') === 'enabled' || (prefersDark && !localStorage.getItem('darkMode'));
  if (isDarkMode) {
    htmlElement.classList.add('dark-mode');
  }

  // Dark mode toggle event listener
  darkModeToggle.addEventListener('click', () => {
    // Toggle dark mode class
    htmlElement.classList.toggle('dark-mode');
    
    // Update local storage
    if (htmlElement.classList.contains('dark-mode')) {
      localStorage.setItem('darkMode', 'enabled');
    } else {
      localStorage.setItem('darkMode', 'disabled');
    }
  });
