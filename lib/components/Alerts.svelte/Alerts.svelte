<script>
  import { alerts } from "$lib/stores";
  import { fly } from "svelte/transition";

  let alertList = [];

  alerts.subscribe((value) => {
    alertList = value;
  });

  function removeAlert(alertId) {
    alerts.update((currentAlerts) =>
      currentAlerts.filter((alert) => alert.id !== alertId)
    );
  }
</script>

<div class="alerts-container">
  {#each alertList as alert (alert.id)}
    <div
      class="alert alert-{alert.type}"
      transition:fly={{ y: -20, duration: 300 }}
    >
      <span>{alert.message}</span>
      <button
        class="alert-close"
        on:click={() => removeAlert(alert.id)}
        aria-label="Lukk melding"
      >
        &times;
      </button>
    </div>
  {/each}
</div>

<style>
  .alerts-container {
    position: fixed;
    top: 80px;
    right: 20px;
    z-index: 1000;
    max-width: 400px;
  }

  .alert {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    margin-bottom: 0.5rem;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .alert-success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
  }

  .alert-error {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
  }

  .alert-warning {
    background-color: #fff3cd;
    color: #856404;
    border: 1px solid #ffeaa7;
  }

  .alert-info {
    background-color: #d1ecf1;
    color: #0c5460;
    border: 1px solid #bee5eb;
  }

  .alert-close {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    padding: 0;
    margin-left: 1rem;
    opacity: 0.7;
  }

  .alert-close:hover {
    opacity: 1;
  }
</style>
