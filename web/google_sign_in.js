function signInWithGoogle() {
    var provider = new firebase.auth.GoogleAuthProvider();
    firebase.auth().signInWithPopup(provider).then(function(result) {
      // This gives you a Google Access Token. You can use it to access the Google API.
      var token = result.credential.accessToken;
      // The signed-in user info.
      var user = result.user;
      // Emit a custom event to notify Flutter about successful sign-in.
      window.dispatchEvent(new CustomEvent('google-sign-in', { detail: token }));
    }).catch(function(error) {
      // Handle errors here.
    });
  }