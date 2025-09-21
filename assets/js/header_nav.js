(() => {
    const navText = document.querySelector(".navbar-tip");
    const initString = navText.innerHTML;

    document.querySelector('nav').addEventListener('mouseleave', () => {
        navText.innerHTML = initString;
    });
    document.querySelectorAll('nav a').forEach((button) => {
        button.addEventListener('mouseenter', () => {
            navText.innerHTML = button.dataset.navText;
        });
    })
})()