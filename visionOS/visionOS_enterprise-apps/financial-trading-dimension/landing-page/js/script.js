// ===================================
// Navigation Scroll Effect
// ===================================
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
});

// ===================================
// Mobile Menu Toggle
// ===================================
const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navMenu = document.querySelector('.nav-menu');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        navMenu.classList.toggle('active');
        mobileMenuToggle.classList.toggle('active');

        // Animate hamburger icon
        const spans = mobileMenuToggle.querySelectorAll('span');
        if (mobileMenuToggle.classList.contains('active')) {
            spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
            spans[1].style.opacity = '0';
            spans[2].style.transform = 'rotate(-45deg) translate(7px, -6px)';
        } else {
            spans[0].style.transform = 'none';
            spans[1].style.opacity = '1';
            spans[2].style.transform = 'none';
        }
    });
}

// Close mobile menu when clicking on a link
document.querySelectorAll('.nav-menu a').forEach(link => {
    link.addEventListener('click', () => {
        navMenu.classList.remove('active');
        mobileMenuToggle.classList.remove('active');
        const spans = mobileMenuToggle.querySelectorAll('span');
        spans[0].style.transform = 'none';
        spans[1].style.opacity = '1';
        spans[2].style.transform = 'none';
    });
});

// ===================================
// Smooth Scroll for Anchor Links
// ===================================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offsetTop = target.offsetTop - 80; // Account for fixed navbar
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    });
});

// ===================================
// FAQ Accordion
// ===================================
document.querySelectorAll('.faq-question').forEach(button => {
    button.addEventListener('click', () => {
        const faqItem = button.parentElement;
        const isActive = faqItem.classList.contains('active');

        // Close all FAQ items
        document.querySelectorAll('.faq-item').forEach(item => {
            item.classList.remove('active');
        });

        // Open clicked item if it wasn't active
        if (!isActive) {
            faqItem.classList.add('active');
        }
    });
});

// ===================================
// Demo Form Handling
// ===================================
const demoForm = document.getElementById('demoForm');
const successModal = document.getElementById('successModal');

if (demoForm) {
    demoForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        // Get form data
        const formData = {
            name: document.getElementById('name').value,
            email: document.getElementById('email').value,
            company: document.getElementById('company').value,
            role: document.getElementById('role').value,
            message: document.getElementById('message').value
        };

        // In production, send to your backend
        console.log('Form submitted:', formData);

        // Simulate API call
        try {
            await simulateAPICall(formData);

            // Show success modal
            showModal();

            // Reset form
            demoForm.reset();

            // Track conversion (replace with your analytics)
            trackConversion('demo_request', formData);
        } catch (error) {
            console.error('Error submitting form:', error);
            alert('Something went wrong. Please try again or contact us directly.');
        }
    });
}

function simulateAPICall(data) {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve({ success: true });
        }, 1000);
    });
}

function showModal() {
    successModal.classList.add('show');
}

function closeModal() {
    successModal.classList.remove('show');
}

// Close modal when clicking outside
successModal?.addEventListener('click', (e) => {
    if (e.target === successModal) {
        closeModal();
    }
});

// Close modal on ESC key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && successModal.classList.contains('show')) {
        closeModal();
    }
});

// ===================================
// Intersection Observer for Animations
// ===================================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
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
document.querySelectorAll('.feature-card, .problem-card, .benefit-card, .step-card, .testimonial-card, .pricing-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// ===================================
// Analytics Tracking
// ===================================
function trackConversion(eventName, data) {
    // Google Analytics 4
    if (typeof gtag !== 'undefined') {
        gtag('event', eventName, {
            ...data
        });
    }

    // Facebook Pixel
    if (typeof fbq !== 'undefined') {
        fbq('track', 'Lead', data);
    }

    // LinkedIn Insight Tag
    if (typeof lintrk !== 'undefined') {
        lintrk('track', { conversion_id: 'your_conversion_id' });
    }

    console.log('Conversion tracked:', eventName, data);
}

// Track CTA clicks
document.querySelectorAll('.btn-primary').forEach(btn => {
    btn.addEventListener('click', (e) => {
        const btnText = btn.textContent.trim();
        trackConversion('cta_click', {
            button_text: btnText,
            button_location: getButtonLocation(btn)
        });
    });
});

function getButtonLocation(button) {
    const section = button.closest('section');
    if (section) {
        return section.className.split(' ')[0].replace('-section', '');
    }
    return 'unknown';
}

// ===================================
// Video Modal (if you add a video)
// ===================================
const videoLinks = document.querySelectorAll('a[href="#video"]');
videoLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        // Open video modal with YouTube/Vimeo embed
        // Implementation depends on your video hosting
        alert('Video demo coming soon! Request a live demo to see the platform in action.');
    });
});

// ===================================
// Dynamic Stats Counter
// ===================================
function animateCounter(element, target, duration = 2000) {
    let start = 0;
    const increment = target / (duration / 16);
    const timer = setInterval(() => {
        start += increment;
        if (start >= target) {
            element.textContent = target + '%';
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(start) + '%';
        }
    }, 16);
}

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.classList.contains('animated')) {
            entry.target.classList.add('animated');
            const value = parseInt(entry.target.textContent);
            animateCounter(entry.target, value);
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat-value').forEach(stat => {
    statsObserver.observe(stat);
});

// ===================================
// Pricing Toggle (Annual/Monthly) - Optional
// ===================================
// If you want to add pricing toggle functionality, uncomment:
/*
const pricingToggle = document.getElementById('pricingToggle');
if (pricingToggle) {
    pricingToggle.addEventListener('change', (e) => {
        const isAnnual = e.target.checked;
        document.querySelectorAll('.price-amount').forEach((price, index) => {
            const monthlyPrices = [299, 899, 'Custom'];
            const annualPrices = [3000, 9000, 'Custom'];
            price.textContent = isAnnual ? annualPrices[index] : monthlyPrices[index];
        });
    });
}
*/

// ===================================
// Copy to Clipboard (for code examples)
// ===================================
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        console.log('Copied to clipboard');
    });
}

// ===================================
// Lazy Loading Images (if you add images)
// ===================================
if ('loading' in HTMLImageElement.prototype) {
    const images = document.querySelectorAll('img[loading="lazy"]');
    images.forEach(img => {
        img.src = img.dataset.src;
    });
} else {
    // Fallback for browsers that don't support lazy loading
    const script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/lazysizes/5.3.2/lazysizes.min.js';
    document.body.appendChild(script);
}

// ===================================
// Scroll Progress Indicator
// ===================================
function updateScrollProgress() {
    const winScroll = document.documentElement.scrollTop || document.body.scrollTop;
    const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    const scrolled = (winScroll / height) * 100;

    // If you want to add a progress bar, create an element and update its width
    // progressBar.style.width = scrolled + '%';
}

window.addEventListener('scroll', updateScrollProgress);

// ===================================
// Exit Intent Popup (Optional)
// ===================================
let exitIntentShown = false;

document.addEventListener('mouseleave', (e) => {
    if (e.clientY < 10 && !exitIntentShown) {
        exitIntentShown = true;
        // Show exit intent popup
        console.log('User is about to leave - show exit intent');
        // You can show a special offer or reminder here
    }
});

// ===================================
// Chatbot Integration (Optional)
// ===================================
// If you want to add Intercom, Drift, or other chatbot:
/*
window.intercomSettings = {
    app_id: "YOUR_APP_ID"
};
(function(){var w=window;var ic=w.Intercom;if(typeof ic==="function"){ic('reattach_activator');ic('update',w.intercomSettings);}else{var d=document;var i=function(){i.c(arguments);};i.q=[];i.c=function(args){i.q.push(args);};w.Intercom=i;var l=function(){var s=d.createElement('script');s.type='text/javascript';s.async=true;s.src='https://widget.intercom.io/widget/YOUR_APP_ID';var x=d.getElementsByTagName('script')[0];x.parentNode.insertBefore(s,x);};if(w.attachEvent){w.attachEvent('onload',l);}else{w.addEventListener('load',l,false);}}})();
*/

// ===================================
// Console Easter Egg
// ===================================
console.log('%c👋 Hello, Developer!', 'font-size: 20px; font-weight: bold; color: #0066FF;');
console.log('%cInterested in joining our team? Check out careers at [your-company].com', 'font-size: 14px; color: #667eea;');
console.log('%c📊 Financial Trading Dimension - Built with ❤️ for traders', 'font-size: 12px; color: #94A3B8;');

// ===================================
// Performance Monitoring
// ===================================
if ('PerformanceObserver' in window) {
    const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
            console.log('Performance:', entry.name, entry.duration);
        }
    });
    observer.observe({ entryTypes: ['measure', 'navigation'] });
}

// ===================================
// Accessibility Enhancements
// ===================================
// Skip to main content
const skipLink = document.querySelector('.skip-to-main');
if (skipLink) {
    skipLink.addEventListener('click', (e) => {
        e.preventDefault();
        document.querySelector('main').focus();
    });
}

// Keyboard navigation for cards
document.querySelectorAll('.feature-card, .pricing-card').forEach(card => {
    card.setAttribute('tabindex', '0');
    card.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            card.click();
        }
    });
});

// ===================================
// Print Optimization
// ===================================
window.addEventListener('beforeprint', () => {
    // Expand all FAQ items for printing
    document.querySelectorAll('.faq-item').forEach(item => {
        item.classList.add('active');
    });
});

window.addEventListener('afterprint', () => {
    // Collapse FAQ items after printing
    document.querySelectorAll('.faq-item').forEach(item => {
        item.classList.remove('active');
    });
});

// ===================================
// Initialize
// ===================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('Financial Trading Dimension landing page loaded');

    // Add any initialization code here
    // For example, loading saved form data from localStorage
    const savedFormData = localStorage.getItem('demoFormData');
    if (savedFormData && demoForm) {
        const data = JSON.parse(savedFormData);
        Object.keys(data).forEach(key => {
            const input = demoForm.querySelector(`[name="${key}"]`);
            if (input) input.value = data[key];
        });
    }

    // Save form data to localStorage on input
    if (demoForm) {
        demoForm.addEventListener('input', () => {
            const formData = new FormData(demoForm);
            const data = Object.fromEntries(formData);
            localStorage.setItem('demoFormData', JSON.stringify(data));
        });
    }
});

// Clear saved form data on successful submission
function clearSavedFormData() {
    localStorage.removeItem('demoFormData');
}

// ===================================
// Detect Device Type
// ===================================
function detectDevice() {
    const ua = navigator.userAgent;
    if (/(tablet|ipad|playbook|silk)|(android(?!.*mobi))/i.test(ua)) {
        return 'tablet';
    }
    if (/Mobile|Android|iP(hone|od)|IEMobile|BlackBerry|Kindle|Silk-Accelerated|(hpw|web)OS|Opera M(obi|ini)/.test(ua)) {
        return 'mobile';
    }
    return 'desktop';
}

const deviceType = detectDevice();
console.log('Device type:', deviceType);

// Add device class to body
document.body.classList.add(`device-${deviceType}`);

// ===================================
// Cookie Consent (Optional)
// ===================================
/*
function showCookieConsent() {
    const consent = localStorage.getItem('cookieConsent');
    if (!consent) {
        // Show cookie consent banner
        const banner = document.createElement('div');
        banner.innerHTML = `
            <div style="position: fixed; bottom: 0; left: 0; right: 0; background: var(--bg-secondary); padding: 1rem; text-align: center; z-index: 9999; border-top: 1px solid var(--border);">
                <p>We use cookies to enhance your experience. <a href="#privacy">Learn more</a></p>
                <button onclick="acceptCookies()" class="btn btn-primary">Accept</button>
            </div>
        `;
        document.body.appendChild(banner);
    }
}

function acceptCookies() {
    localStorage.setItem('cookieConsent', 'true');
    document.querySelector('[style*="position: fixed"]')?.remove();
}

// Uncomment to enable cookie consent
// showCookieConsent();
*/
