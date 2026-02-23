function showMessage(message, error) {
    if (message) {
        alert(message);
    }
    if (error) {
        alert(error);
    }
}

window.onload = function() {
    // JSP에서 변수 삽입
    if (typeof serverMessage !== "undefined" || typeof serverError !== "undefined") {
        showMessage(serverMessage, serverError);
    }
};
