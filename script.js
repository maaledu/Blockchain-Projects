document.addEventListener('DOMContentLoaded', () => {
    const keys = document.querySelectorAll('.key');
    const sounds = {
        'A': new Audio('sounds/a.mp3'),
        'S': new Audio('sounds/s.mp3'),
        'D': new Audio('sounds/d.mp3'),
        'F': new Audio('sounds/f.mp3')
    };

    keys.forEach(key => {
        key.addEventListener('click', () => {
            const sound = sounds[key.dataset.key];
            if (sound) {
                sound.currentTime = 0;
                sound.play();
            }
        });
    });

    document.addEventListener('keydown', (event) => {
        const key = event.key.toUpperCase();
        const sound = sounds[key];
        if (sound) {
            sound.currentTime = 0;
            sound.play();
            document.querySelector(`.key[data-key="${key}"]`).classList.add('active');
        }
    });

    document.addEventListener('keyup', (event) => {
        const key = event.key.toUpperCase();
        document.querySelector(`.key[data-key="${key}"]`).classList.remove('active');
    });
});