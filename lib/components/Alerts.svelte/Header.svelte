<script>
  import { currentUser, showAlert } from "$lib/stores";

  export let currentTab = "register";
  export let showLoginModal = false;

  let user = null;

  currentUser.subscribe((value) => {
    user = value;
  });

  function handleNavigation(tab) {
    currentTab = tab;
  }

  function handleLoginLogout() {
    if (user) {
      currentUser.set(null);
      showAlert("Du er nå logget ut", "info");
      // Navigate back to registration if on admin page
      if (currentTab === "admin") {
        currentTab = "register";
      }
    } else {
      showLoginModal = true;
    }
  }

  $: navigationItems = [
    { id: "register", label: "Registrering", visible: true },
    { id: "statistics", label: "Statistikk", visible: true },
    { id: "export", label: "Eksport", visible: true },
    { id: "contact", label: "Kontakt", visible: true },
    {
      id: "admin",
      label: "Administrer",
      visible: user && user.role === "admin",
    },
  ].filter((item) => item.visible);
</script>

<header class="site-header">
  <div class="container">
    <div class="header-content">
      <div class="logo">
        <h1>Blodtrykksmålinger - Støtteverktøy</h1>
      </div>
      <nav class="main-nav">
        <ul class="nav-list">
          {#each navigationItems as item}
            <li>
              <button
                class="nav-link {currentTab === item.id ? 'active' : ''}"
                on:click={() => handleNavigation(item.id)}
              >
                {item.label}
              </button>
            </li>
          {/each}
          <li>
            <button class="nav-link login-link" on:click={handleLoginLogout}>
              {user ? "Logg ut" : "Logg inn"}
            </button>
          </li>
        </ul>
      </nav>
    </div>

    {#if user}
      <div class="user-info">
        Innlogget som: <strong>{user.username}</strong>
        ({user.role === "admin" ? "Administrator" : "Ansatt"})
      </div>
    {/if}
  </div>
</header>

<style>
  .site-header {
    background-color: #ffffff;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    position: sticky;
    top: 0;
    z-index: 100;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 0;
  }

  .logo h1 {
    margin: 0;
    color: #007bff;
    font-size: 1.5rem;
    font-weight: 600;
  }

  .nav-list {
    display: flex;
    list-style: none;
    margin: 0;
    padding: 0;
    gap: 0.5rem;
  }

  .nav-link {
    background: none;
    border: none;
    padding: 0.75rem 1rem;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    color: #495057;
    text-decoration: none;
    transition: all 0.2s;
    white-space: nowrap;
  }

  .nav-link:hover {
    background-color: #f8f9fa;
    color: #007bff;
  }

  .nav-link.active {
    background-color: #007bff;
    color: white;
  }

  .login-link {
    background-color: #28a745;
    color: white;
  }

  .login-link:hover {
    background-color: #218838;
  }

  .user-info {
    background-color: #f8f9fa;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    font-size: 0.875rem;
    color: #495057;
    margin-top: 0.5rem;
  }

  @media (max-width: 768px) {
    .header-content {
      flex-direction: column;
      gap: 1rem;
    }

    .logo h1 {
      font-size: 1.25rem;
      text-align: center;
    }

    .nav-list {
      flex-wrap: wrap;
      justify-content: center;
      gap: 0.25rem;
    }

    .nav-link {
      padding: 0.5rem 0.75rem;
      font-size: 0.875rem;
    }
  }

  @media (max-width: 480px) {
    .nav-list {
      flex-direction: column;
      width: 100%;
    }

    .nav-link {
      width: 100%;
      text-align: center;
    }
  }
</style>
