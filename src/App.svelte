<script>
  import { onMount } from "svelte";
  import Header from "$lib/components/Header.svelte";
  import Footer from "$lib/components/Footer.svelte";
  import Alerts from "$lib/components/Alerts.svelte";
  import LoginModal from "$lib/components/LoginModal.svelte";
  import Registration from "$lib/components/Registration.svelte";
  import Statistics from "$lib/components/Statistics.svelte";
  import Export from "$lib/components/Export.svelte";
  import Contact from "$lib/components/Contact.svelte";
  import Admin from "$lib/components/Admin.svelte";
  import { currentUser, bpRecords, generateUniqueId } from "$lib/stores";

  let currentTab = "register";
  let showLoginModal = false;
  let user = null;

  // Subscribe to user changes
  currentUser.subscribe((value) => {
    user = value;
    // If user logs out and is on admin page, redirect to registration
    if (!value && currentTab === "admin") {
      currentTab = "register";
    }
  });

  onMount(() => {
    // Generate sample data if no records exist
    bpRecords.subscribe((records) => {
      if (records.length === 0) {
        generateSampleData();
      }
    })();
  });

  function generateSampleData() {
    const sampleData = [
      {
        patientId: "P001",
        age: 45,
        gender: "male",
        sys: 135,
        dia: 88,
        source: "maja",
      },
      {
        patientId: "P002",
        age: 62,
        gender: "female",
        sys: 165,
        dia: 95,
        source: "self",
      },
      {
        patientId: "P003",
        age: 38,
        gender: "male",
        sys: 125,
        dia: 80,
        source: "maja",
      },
      {
        patientId: "P004",
        age: 55,
        gender: "female",
        sys: 145,
        dia: 92,
        source: "doctor",
      },
      {
        patientId: "P005",
        age: 71,
        gender: "male",
        sys: 155,
        dia: 98,
        source: "self",
      },
      {
        patientId: "P006",
        age: 29,
        gender: "female",
        sys: 115,
        dia: 75,
        source: "maja",
      },
      {
        patientId: "P007",
        age: 48,
        gender: "male",
        sys: 140,
        dia: 90,
        source: "self",
      },
      {
        patientId: "P008",
        age: 66,
        gender: "female",
        sys: 170,
        dia: 105,
        source: "doctor",
      },
    ];

    const sampleRecords = sampleData.map((data, i) => {
      const date = new Date();
      date.setDate(date.getDate() - i);

      return {
        id: generateUniqueId(),
        patientId: data.patientId,
        patientAge: data.age,
        patientGender: data.gender,
        measurementDate: date.toISOString().split("T")[0],
        measurementTime: `${10 + Math.floor(Math.random() * 8)}:${String(Math.floor(Math.random() * 60)).padStart(2, "0")}`,
        referralSource: data.source,
        measurement1Sys: data.sys + Math.floor(Math.random() * 20) - 10,
        measurement1Dia: data.dia + Math.floor(Math.random() * 10) - 5,
        measurement2Sys: data.sys + Math.floor(Math.random() * 10) - 5,
        measurement2Dia: data.dia + Math.floor(Math.random() * 6) - 3,
        measurement3Sys: data.sys + Math.floor(Math.random() * 10) - 5,
        measurement3Dia: data.dia + Math.floor(Math.random() * 6) - 3,
        averageSys: data.sys,
        averageDia: data.dia,
        equipment: ["microlife-b2", "microlife-b6", "llp-bt"][
          Math.floor(Math.random() * 3)
        ],
        cuffSize: ["S", "M/L", "L/XL"][Math.floor(Math.random() * 3)],
        armUsed: ["left", "right"][Math.floor(Math.random() * 2)],
        notes: Math.random() > 0.7 ? "Pasient var nervøs under måling" : "",
        registeredAt: date.toISOString(),
        registeredBy: "Demo",
      };
    });

    bpRecords.set(sampleRecords);
  }
</script>

<div class="app">
  <Header bind:currentTab bind:showLoginModal />

  <main class="main-content">
    <Alerts />

    {#if currentTab === "register"}
      <Registration />
    {:else if currentTab === "statistics"}
      <Statistics />
    {:else if currentTab === "export"}
      <Export />
    {:else if currentTab === "contact"}
      <Contact />
    {:else if currentTab === "admin" && user && user.role === "admin"}
      <Admin />
    {:else}
      <div class="error-message">
        <h2>Siden ikke funnet</h2>
        <p>
          Den forespurte siden eksisterer ikke eller du har ikke tilgang til
          den.
        </p>
        <button
          class="btn btn-primary"
          on:click={() => (currentTab = "register")}
        >
          Tilbake til registrering
        </button>
      </div>
    {/if}
  </main>

  <Footer />

  <LoginModal bind:isOpen={showLoginModal} />
</div>

<style>
  :global(html, body) {
    margin: 0;
    padding: 0;
    min-height: 100vh;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
      Ubuntu, Cantarell, sans-serif;
    background-color: #f8f9fa;
  }

  :global(*) {
    box-sizing: border-box;
  }

  .app {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  .main-content {
    flex: 1;
    padding: 2rem 0;
  }

  .error-message {
    max-width: 600px;
    margin: 2rem auto;
    padding: 2rem;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    text-align: center;
  }

  .error-message h2 {
    color: #dc3545;
    margin-bottom: 1rem;
  }

  .error-message p {
    color: #6c757d;
    margin-bottom: 1.5rem;
  }

  .btn {
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.2s;
  }

  .btn-primary {
    background-color: #007bff;
    color: white;
  }

  .btn-primary:hover {
    background-color: #0056b3;
  }

  /* Global styles for consistency */
  :global(.container) {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
  }

  :global(.card) {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 1.5rem;
    margin-bottom: 1.5rem;
  }

  :global(.btn) {
    padding: 0.75rem 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.2s;
    text-decoration: none;
    display: inline-block;
    text-align: center;
  }

  :global(.btn:disabled) {
    opacity: 0.6;
    cursor: not-allowed;
  }

  :global(.btn-primary) {
    background-color: #007bff;
    color: white;
  }

  :global(.btn-primary:hover:not(:disabled)) {
    background-color: #0056b3;
  }

  :global(.btn-secondary) {
    background-color: #6c757d;
    color: white;
  }

  :global(.btn-secondary:hover:not(:disabled)) {
    background-color: #545b62;
  }

  :global(.btn-success) {
    background-color: #28a745;
    color: white;
  }

  :global(.btn-success:hover:not(:disabled)) {
    background-color: #218838;
  }

  :global(.btn-info) {
    background-color: #17a2b8;
    color: white;
  }

  :global(.btn-info:hover:not(:disabled)) {
    background-color: #138496;
  }

  :global(.btn-danger) {
    background-color: #dc3545;
    color: white;
  }

  :global(.btn-danger:hover:not(:disabled)) {
    background-color: #c82333;
  }

  :global(.form-group) {
    margin-bottom: 1rem;
  }

  :global(.form-group label) {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #495057;
  }

  :global(.form-group input, .form-group select, .form-group textarea) {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ced4da;
    border-radius: 4px;
    font-size: 1rem;
  }

  :global(
      .form-group input:focus,
      .form-group select:focus,
      .form-group textarea:focus
    ) {
    outline: none;
    border-color: #80bdff;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  }

  :global(.input-group) {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }

  /* Responsive design */
  @media (max-width: 768px) {
    :global(.input-group) {
      grid-template-columns: 1fr;
    }

    .main-content {
      padding: 1rem 0;
    }
  }
</style>
