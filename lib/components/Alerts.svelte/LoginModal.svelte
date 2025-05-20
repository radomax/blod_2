<script>
  import { onMount } from "svelte";
  import { currentUser, showAlert } from "$lib/stores";

  export let isOpen = false;

  let username = "";
  let password = "";
  let role = "user";
  let loginForm;

  function closeModal() {
    isOpen = false;
    username = "";
    password = "";
    role = "user";
  }

  function handleLogin(event) {
    event.preventDefault();

    if (!username || !password) {
      showAlert("Vennligst fyll ut alle feltene", "error");
      return;
    }

    // Simple login validation - in real app, validate against backend
    currentUser.set({ username, role });
    showAlert(
      `Innlogget som ${username} (${role === "admin" ? "Administrator" : "Ansatt"})`,
      "success"
    );
    closeModal();
  }

  function handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      closeModal();
    }
  }

  // Handle escape key
  function handleKeydown(event) {
    if (event.key === "Escape") {
      closeModal();
    }
  }

  onMount(() => {
    document.addEventListener("keydown", handleKeydown);
    return () => document.removeEventListener("keydown", handleKeydown);
  });
</script>

{#if isOpen}
  <div
    class="modal-backdrop"
    on:click={handleBackdropClick}
    on:keydown={handleKeydown}
    role="dialog"
    aria-labelledby="modal-title"
    aria-modal="true"
  >
    <div class="modal">
      <div class="modal-header">
        <h3 class="modal-title" id="modal-title">Logg inn</h3>
        <button class="modal-close" on:click={closeModal}>&times;</button>
      </div>
      <div class="modal-body">
        <form bind:this={loginForm} on:submit={handleLogin}>
          <div class="form-group">
            <label for="username">Brukernavn</label>
            <input type="text" id="username" bind:value={username} required />
          </div>
          <div class="form-group">
            <label for="password">Passord</label>
            <input
              type="password"
              id="password"
              bind:value={password}
              required
            />
          </div>
          <div class="form-group">
            <label for="role">Rolle</label>
            <select id="role" bind:value={role}>
              <option value="user">Ansatt</option>
              <option value="admin">Administrator</option>
            </select>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" on:click={closeModal}>Avbryt</button>
        <button class="btn" on:click={handleLogin}>Logg inn</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }

  .modal {
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    max-width: 400px;
    width: 90%;
    max-height: 90vh;
    overflow-y: auto;
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    border-bottom: 1px solid #e5e5e5;
  }

  .modal-title {
    margin: 0;
    font-size: 1.25rem;
  }

  .modal-close {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    padding: 0;
  }

  .modal-body {
    padding: 1rem;
  }

  .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 0.5rem;
    padding: 1rem;
    border-top: 1px solid #e5e5e5;
  }

  .form-group {
    margin-bottom: 1rem;
  }

  .form-group label {
    display: block;
    margin-bottom: 0.25rem;
    font-weight: 500;
  }

  .form-group input,
  .form-group select {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 1rem;
  }

  .btn {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    background-color: #007bff;
    color: white;
  }

  .btn:hover {
    background-color: #0056b3;
  }

  .btn-secondary {
    background-color: #6c757d;
    color: white;
  }

  .btn-secondary:hover {
    background-color: #545b62;
  }
</style>
