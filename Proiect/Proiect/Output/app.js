document.addEventListener("DOMContentLoaded", () => {
  // --- STATE ---
  let currentSlide = 0;
  const slides = document.querySelectorAll(".slide");
  const totalSlides = slides.length;

  // --- DOM ELEMENTS ---
  const btnNext = document.getElementById("next-slide");
  const btnPrev = document.getElementById("prev-slide");
  const slideIndicator = document.getElementById("slide-indicator");
  const progressBar = document.getElementById("progress-bar");

  // --- INIT ---
  updateUI();

  // Create Lightbox
  const lightbox = document.createElement("div");
  lightbox.id = "lightbox";
  document.body.appendChild(lightbox);

  const lightboxImg = document.createElement("img");
  lightbox.appendChild(lightboxImg);

  lightbox.addEventListener("click", () => {
    lightbox.classList.remove("active");
  });

  // --- NAVIGATION LOGIC ---
  function goToSlide(index) {
    if (index < 0 || index >= totalSlides) return;

    // Hide all
    slides.forEach((s) => s.classList.remove("active"));

    // Show target
    currentSlide = index;
    slides[currentSlide].classList.add("active");

    // Scroll to top
    document.getElementById("presentation-container").scrollTop = 0;

    updateUI();
  }

  function nextSlide() {
    goToSlide(currentSlide + 1);
  }
  function prevSlide() {
    goToSlide(currentSlide - 1);
  }

  function updateUI() {
    // Buttons
    btnPrev.disabled = currentSlide === 0;
    btnNext.disabled = currentSlide === totalSlides - 1;
    btnPrev.style.opacity = currentSlide === 0 ? "0.3" : "1";
    btnNext.style.opacity = currentSlide === totalSlides - 1 ? "0.3" : "1";

    // Indicator
    slideIndicator.textContent = `${currentSlide + 1} / ${totalSlides}`;

    // Progress Bar
    const progress = ((currentSlide + 1) / totalSlides) * 100;
    progressBar.style.width = `${progress}%`;
  }

  // --- EVENT LISTENERS ---
  btnNext.addEventListener("click", nextSlide);
  btnPrev.addEventListener("click", prevSlide);

  // Keyboard Support
  document.addEventListener("keydown", (e) => {
    if (e.key === "ArrowRight" || e.key === " ") nextSlide();
    if (e.key === "ArrowLeft") prevSlide();
  });

  // Lightbox Triggers
  document.querySelectorAll(".lightbox-trigger").forEach((img) => {
    img.addEventListener("click", () => {
      lightboxImg.src = img.src;
      lightbox.classList.add("active");
    });
  });

  console.log(`Presentation loaded with ${totalSlides} slides.`);
});
