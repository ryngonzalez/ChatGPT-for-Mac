document.addEventListener("keydown", e => {
    if (window.location.href.includes("https://chat.openai.com/chat") && e.code == "Enter" && e.target.tagName == "TEXTAREA") {
        if (e.target.nextSibling.tagName == "BUTTON" && e.shiftKey == false) {
            e.preventDefault()
            e.target.nextSibling.click()
        }
    }
})
