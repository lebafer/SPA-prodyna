<template>
    <div>
      <h1>Frontend</h1>
      <p>Status: {{ status }}</p>
    </div>
  </template>
  
  <script>
  export default {
    data() {
      return {
        status: 'loading...'
      };
    },
    mounted() {
      fetch(`${import.meta.env.VUE_APP_API_URL}/health`)
        .then(response => response.json())
        .then(data => {
          this.status = data.status;
        })
        .catch(() => {
          this.status = 'error';
        });
    }
  };
  </script>
