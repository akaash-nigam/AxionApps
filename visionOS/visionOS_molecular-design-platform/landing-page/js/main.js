// Molecular Design Platform - Main JavaScript

// Smooth scroll for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offsetTop = target.offsetTop - 80;
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    });
});

// Navbar scroll effect
let lastScrollTop = 0;
const navbar = document.querySelector('.navbar');

window.addEventListener('scroll', () => {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

    if (scrollTop > 100) {
        navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
    } else {
        navbar.style.boxShadow = 'none';
    }

    lastScrollTop = scrollTop;
});

// Intersection Observer for fade-in animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all cards and sections
document.querySelectorAll('.feature-card, .problem-card, .step-card, .testimonial-card, .pricing-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Demo form submission
const demoForm = document.querySelector('.demo-form');
if (demoForm) {
    demoForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = new FormData(demoForm);
        const data = Object.fromEntries(formData);

        // Show loading state
        const submitButton = demoForm.querySelector('button[type="submit"]');
        const originalText = submitButton.textContent;
        submitButton.textContent = 'Sending...';
        submitButton.disabled = true;

        // Simulate form submission (replace with actual API call)
        setTimeout(() => {
            // Show success message
            submitButton.textContent = 'Request Sent! ✓';
            submitButton.style.background = 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)';

            // Reset form
            demoForm.reset();

            // Reset button after 3 seconds
            setTimeout(() => {
                submitButton.textContent = originalText;
                submitButton.disabled = false;
                submitButton.style.background = '';
            }, 3000);

            // Log form data (for demonstration)
            console.log('Demo request:', data);

            // You would replace this with actual API call:
            // try {
            //     const response = await fetch('/api/demo-request', {
            //         method: 'POST',
            //         headers: { 'Content-Type': 'application/json' },
            //         body: JSON.stringify(data)
            //     });
            //     const result = await response.json();
            //     console.log('Success:', result);
            // } catch (error) {
            //     console.error('Error:', error);
            //     submitButton.textContent = 'Error - Try Again';
            // }
        }, 1500);
    });
}

// Add counter animation for stats
const animateCounter = (element, target, duration = 2000) => {
    const start = 0;
    const increment = target / (duration / 16); // 60fps
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = formatStatNumber(target);
            clearInterval(timer);
        } else {
            element.textContent = formatStatNumber(Math.floor(current));
        }
    }, 16);
};

const formatStatNumber = (num) => {
    if (num >= 1000000000) {
        return (num / 1000000000).toFixed(1) + 'B';
    }
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    }
    if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toString();
};

// Observe stat numbers for counter animation
const statObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            const statCards = entry.target.querySelectorAll('.stat-card');
            statCards.forEach((card, index) => {
                const numberElement = card.querySelector('.stat-number');
                if (numberElement) {
                    const text = numberElement.textContent.trim();

                    // Extract number from text like "75%", "3x", "$5B"
                    let targetNumber;
                    if (text.includes('%')) {
                        targetNumber = parseInt(text);
                        setTimeout(() => {
                            let current = 0;
                            const interval = setInterval(() => {
                                current += 1;
                                if (current >= targetNumber) {
                                    numberElement.textContent = targetNumber + '%';
                                    clearInterval(interval);
                                } else {
                                    numberElement.textContent = current + '%';
                                }
                            }, 30);
                        }, index * 200);
                    } else if (text.includes('x')) {
                        targetNumber = parseInt(text);
                        setTimeout(() => {
                            let current = 0;
                            const interval = setInterval(() => {
                                current += 0.1;
                                if (current >= targetNumber) {
                                    numberElement.textContent = targetNumber + 'x';
                                    clearInterval(interval);
                                } else {
                                    numberElement.textContent = current.toFixed(1) + 'x';
                                }
                            }, 50);
                        }, index * 200);
                    } else if (text.includes('$')) {
                        // Keep as is for dollar amounts
                        numberElement.style.opacity = '0';
                        setTimeout(() => {
                            numberElement.style.transition = 'opacity 0.5s ease';
                            numberElement.style.opacity = '1';
                        }, index * 200);
                    }
                }
            });
            entry.target.dataset.animated = 'true';
        }
    });
}, { threshold: 0.5 });

const statsSection = document.querySelector('.stats-section .container');
if (statsSection) {
    statObserver.observe(statsSection);
}

// Parallax effect for hero molecule
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroVisual = document.querySelector('.hero-visual');

    if (heroVisual && scrolled < 1000) {
        heroVisual.style.transform = `translateY(${scrolled * 0.3}px)`;
    }
});

// Add hover effect to molecule atoms
const moleculeSVG = document.querySelector('.molecule-svg');
if (moleculeSVG) {
    const atoms = moleculeSVG.querySelectorAll('circle');
    atoms.forEach(atom => {
        atom.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.2)';
            this.style.transformOrigin = 'center';
            this.style.transition = 'transform 0.3s ease';
        });

        atom.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1)';
        });
    });
}

// Add typing effect to hero title (optional enhancement)
const heroTitle = document.querySelector('.hero-title');
if (heroTitle) {
    const text = heroTitle.innerHTML;
    heroTitle.innerHTML = '';
    let i = 0;

    const typeWriter = () => {
        if (i < text.length) {
            heroTitle.innerHTML += text.charAt(i);
            i++;
            setTimeout(typeWriter, 30);
        }
    };

    // Uncomment to enable typing effect:
    // typeWriter();
}

// Handle video modal (if video section is added)
const videoButtons = document.querySelectorAll('a[href="#video"]');
videoButtons.forEach(button => {
    button.addEventListener('click', (e) => {
        e.preventDefault();
        // Create modal for video
        const modal = document.createElement('div');
        modal.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.9);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10000;
        `;

        modal.innerHTML = `
            <div style="position: relative; width: 90%; max-width: 1200px;">
                <button onclick="this.parentElement.parentElement.remove()" style="
                    position: absolute;
                    top: -40px;
                    right: 0;
                    background: white;
                    border: none;
                    width: 40px;
                    height: 40px;
                    border-radius: 50%;
                    cursor: pointer;
                    font-size: 24px;
                ">×</button>
                <div style="background: #000; padding-bottom: 56.25%; position: relative;">
                    <iframe
                        style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"
                        src="https://www.youtube.com/embed/dQw4w9WgXcQ"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                    </iframe>
                </div>
            </div>
        `;

        document.body.appendChild(modal);

        // Close on click outside
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.remove();
            }
        });
    });
});

// Log page load
console.log('🧪 Molecular Design Platform - Landing Page Loaded');
console.log('Built with ❤️ for Apple Vision Pro');
