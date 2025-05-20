<script>
  let currentTab = "register";
  let showLoginModal = false;
</script>

<svelte:head>
  <title>Blodtrykksmålinger - Støtteverktøy</title>
</svelte:head>

<div class="app">
  <header class="site-header">
    <div class="container">
      <h1>Blodtrykksmålinger - Støtteverktøy</h1>
      <nav>
        <button
          class="nav-link {currentTab === 'register' ? 'active' : ''}"
          on:click={() => (currentTab = "register")}
        >
          Registrering
        </button>
        <button
          class="nav-link {currentTab === 'statistics' ? 'active' : ''}"
          on:click={() => (currentTab = "statistics")}
        >
          Statistikk
        </button>
        <button
          class="nav-link {currentTab === 'export' ? 'active' : ''}"
          on:click={() => (currentTab = "export")}
        >
          Eksport
        </button>
        <button
          class="nav-link {currentTab === 'contact' ? 'active' : ''}"
          on:click={() => (currentTab = "contact")}
        >
          Kontakt
        </button>
      </nav>
    </div>
  </header>

  <main class="main-content">
    {#if currentTab === "register"}
      <div class="container">
        <div class="card">
          <h2>Registrering av blodtrykksmålinger</h2>
          <p>
            Dette er registreringssiden. Komponenter vil bli lagt til snart.
          </p>
        </div>
      </div>
    {:else if currentTab === "statistics"}
      <div class="container">
        <div class="card">
          <h2>Statistikk og oversikt</h2>
          <p>Dette er statistikksiden. Komponenter vil bli lagt til snart.</p>
        </div>
      </div>
    {:else if currentTab === "export"}
      <div class="container">
        <div class="card">
          <h2>Eksporter data</h2>
          <p>Dette er eksportsiden. Komponenter vil bli lagt til snart.</p>
        </div>
      </div>
    {:else if currentTab === "contact"}
      <div class="container">
        <div class="card">
          <h2>Kontakt oss</h2>
          <p>Dette er kontaktsiden. Komponenter vil bli lagt til snart.</p>
        </div>
      </div>
    {/if}
  </main>

  <footer class="site-footer">
    <div class="container">
      <p>&copy; 2025 Blodtrykksmålinger. Alle rettigheter forbeholdt.</p>
    </div>
  </footer>
</div>

<style>
  .app {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  .site-header {
    background-color: #ffffff;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 1rem 0;
  }

  .site-header h1 {
    color: #007bff;
    margin: 0 0 1rem 0;
  }

  nav {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
  }

  .nav-link {
    background: none;
    border: none;
    padding: 0.75rem 1rem;
    border-radius: 4px;
    cursor: pointer;
    color: #495057;
    transition: all 0.2s;
  }

  .nav-link:hover {
    background-color: #f8f9fa;
    color: #007bff;
  }

  .nav-link.active {
    background-color: #007bff;
    color: white;
  }

  .main-content {
    flex: 1;
    padding: 2rem 0;
  }

  .site-footer {
    background-color: #343a40;
    color: white;
    padding: 1rem 0;
    text-align: center;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
  }

  .card {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 2rem;
    margin-bottom: 1.5rem;
  }

  .card h2 {
    color: #495057;
    margin-bottom: 1rem;
  }

  @media (max-width: 768px) {
    nav {
      flex-direction: column;
    }

    .nav-link {
      width: 100%;
      text-align: center;
    }
  }
</style>
