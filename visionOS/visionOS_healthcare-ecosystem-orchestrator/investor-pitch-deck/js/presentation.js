let currentSlide = 1;
const totalSlides = 16;

function showSlide(n) {
    const slides = document.querySelectorAll('.slide');

    if (n > totalSlides) currentSlide = 1;
    if (n < 1) currentSlide = totalSlides;

    slides.forEach(slide => slide.classList.remove('active'));
    slides[currentSlide - 1].classList.add('active');

    document.getElementById('current-slide').textContent = currentSlide;
    document.getElementById('progress-fill').style.width = `${(currentSlide / totalSlides) * 100}%`;

    // Disable/enable buttons
    document.getElementById('prev-btn').disabled = currentSlide === 1;
    document.getElementById('next-btn').disabled = currentSlide === totalSlides;
}

function nextSlide() {
    currentSlide++;
    showSlide(currentSlide);
}

function prevSlide() {
    currentSlide--;
    showSlide(currentSlide);
}

// Keyboard navigation
document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight' || e.key === ' ') {
        e.preventDefault();
        nextSlide();
    } else if (e.key === 'ArrowLeft') {
        e.preventDefault();
        prevSlide();
    }
});

// Button navigation
document.getElementById('next-btn').addEventListener('click', nextSlide);
document.getElementById('prev-btn').addEventListener('click', prevSlide);

// Initialize
document.getElementById('total-slides').textContent = totalSlides;
showSlide(1);
