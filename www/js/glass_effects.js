// Dynamic liquid glass effects
(function() {
  function initLiquidGlass() {
    const cards = document.querySelectorAll('.glass-effect');
    
    cards.forEach(card => {
      // Skip tilt effect if card has 'no-tilt' class
      if (card.classList.contains('no-tilt')) {
        return; // Skip this card entirely
      }

      let isHovered = false;
      
      // Add subtle parallax on mouse move (only for cards without no-tilt)
      card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width;
        const y = (e.clientY - rect.top) / rect.height;

        const isStatCard = card.classList.contains('stat-card');
        
        // Subtle transform based on mouse position
        const tiltX = (y - 0.5) * 5;
        const tiltY = (x - 0.5) * -5;
        
        card.style.transform = `perspective(1000px) rotateX(${tiltX}deg) rotateY(${tiltY}deg) scale(1.01)`;
      });
      
      card.addEventListener('mouseleave', () => {
        card.style.transform = '';
      });
    });
  }
  
  // Initialize on DOM ready
  if (document.readyState !== 'loading') {
    initLiquidGlass();
  } else {
    document.addEventListener('DOMContentLoaded', initLiquidGlass);
  }
  
  // Reinitialize on Shiny redraws
  if (window.Shiny) {
    $(document).on('shiny:value', initLiquidGlass);
  }
})();