<script>
  import { onMount } from "svelte";
  import { bpRecords, categorizeBP, formatDate } from "$lib/stores";
  import { getStatistics, getMeasurements } from "$lib/api";

  let statistics = {
    total: 0,
    today: 0,
    highBP: 0,
    avgAge: 0,
  };

  let recentRecords = [];
  let isLoading = true;

  onMount(async () => {
    await loadData();
  });

  async function loadData() {
    isLoading = true;

    try {
      // Load statistics
      const statsResult = await getStatistics();
      if (statsResult.success) {
        statistics = statsResult.data;
      }

      // Load recent measurements
      const recordsResult = await getMeasurements({ limit: 10 });
      if (recordsResult.success) {
        recentRecords = recordsResult.data;
        bpRecords.set(recordsResult.data);
      }
    } catch (error) {
      console.error("Error loading data:", error);
      // Use local data if API fails
      bpRecords.subscribe((records) => {
        recentRecords = records.slice(0, 10);
        updateLocalStatistics(records);
      });
    } finally {
      isLoading = false;
    }
  }

  function updateLocalStatistics(records) {
    const totalMeasurements = records.length;
    const today = new Date().toISOString().split("T")[0];
    const todayMeasurements = records.filter(
      (r) => r.measurementDate === today
    ).length;

    const highBPCount = records.filter((record) => {
      const category = categorizeBP(record.averageSys, record.averageDia);
      return category.key === "high" || category.key === "veryHigh";
    }).length;

    const highBPPercentage =
      totalMeasurements > 0
        ? Math.round((highBPCount / totalMeasurements) * 100)
        : 0;
    const avgAge =
      totalMeasurements > 0
        ? Math.round(
            records.reduce((sum, r) => sum + (r.patientAge || 0), 0) /
              totalMeasurements
          )
        : 0;

    statistics = {
      total: totalMeasurements,
      today: todayMeasurements,
      highBP: highBPPercentage,
      avgAge,
    };
  }

  function getReferralSourceLabel(source) {
    const labels = {
      maja: "Maja.no",
      self: "Eget initiativ",
      doctor: "Lege",
      other: "Annet",
    };
    return labels[source] || source;
  }
</script>

<section class="statistics-section">
  <h1>Statistikk og oversikt</h1>
  <p>Få oversikt over registrerte blodtrykksmålinger.</p>

  {#if isLoading}
    <div class="loading">Laster data...</div>
  {:else}
    <div class="stats-grid">
      <div class="stats-card">
        <span class="stats-number">{statistics.total}</span>
        <span class="stats-label">Totale målinger</span>
      </div>
      <div class="stats-card">
        <span class="stats-number">{statistics.today}</span>
        <span class="stats-label">Målinger i dag</span>
      </div>
      <div class="stats-card">
        <span class="stats-number">{statistics.highBP}%</span>
        <span class="stats-label">Forhøyet blodtrykk</span>
      </div>
      <div class="stats-card">
        <span class="stats-number">{statistics.avgAge} år</span>
        <span class="stats-label">Gjennomsnittsalder</span>
      </div>
    </div>

    <div class="card">
      <h2>Siste registreringer</h2>
      {#if recentRecords.length > 0}
        <div class="table-responsive">
          <table class="recent-measurements">
            <thead>
              <tr>
                <th>Dato</th>
                <th>Pasient ID</th>
                <th>Alder</th>
                <th>Blodtrykk</th>
                <th>Kategori</th>
                <th>Kilde</th>
              </tr>
            </thead>
            <tbody>
              {#each recentRecords as record}
                {@const category = categorizeBP(
                  record.averageSys,
                  record.averageDia
                )}
                <tr>
                  <td>{formatDate(record.measurementDate)}</td>
                  <td>{record.patientId}</td>
                  <td>{record.patientAge}</td>
                  <td>{record.averageSys}/{record.averageDia}</td>
                  <td>
                    <span class="pressure-status {category.class}">
                      {category.label}
                    </span>
                  </td>
                  <td>{getReferralSourceLabel(record.referralSource)}</td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {:else}
        <p>Ingen registreringer enda.</p>
      {/if}
    </div>
  {/if}

  <div class="card">
    <h2>Handlinger</h2>
    <div class="action-buttons">
      <button class="btn btn-primary" on:click={loadData}>
        Oppdater data
      </button>
    </div>
  </div>
</section>

<style>
  .statistics-section {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }

  .loading {
    text-align: center;
    padding: 2rem;
    color: #6c757d;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin: 2rem 0;
  }

  .stats-card {
    background: white;
    padding: 1.5rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    text-align: center;
    border: 1px solid #e9ecef;
  }

  .stats-number {
    display: block;
    font-size: 2rem;
    font-weight: bold;
    color: #007bff;
    margin-bottom: 0.5rem;
  }

  .stats-label {
    display: block;
    color: #6c757d;
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .card {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 2rem;
    margin-bottom: 2rem;
  }

  .card h2 {
    margin-bottom: 1.5rem;
    color: #495057;
  }

  .table-responsive {
    overflow-x: auto;
  }

  .recent-measurements {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1rem;
  }

  .recent-measurements th,
  .recent-measurements td {
    padding: 0.75rem;
    text-align: left;
    border-bottom: 1px solid #e9ecef;
  }

  .recent-measurements th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
  }

  .recent-measurements tr:hover {
    background-color: #f8f9fa;
  }

  .pressure-status {
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-weight: 500;
    font-size: 0.875rem;
  }

  .pressure-normal {
    background-color: #d4edda;
    color: #155724;
  }

  .pressure-high-normal {
    background-color: #fff3cd;
    color: #856404;
  }

  .pressure-high {
    background-color: #f8d7da;
    color: #721c24;
  }

  .pressure-very-high {
    background-color: #f5c6cb;
    color: #721c24;
  }

  .action-buttons {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
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

  @media (max-width: 768px) {
    .stats-grid {
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    }

    .recent-measurements {
      font-size: 0.875rem;
    }

    .recent-measurements th,
    .recent-measurements td {
      padding: 0.5rem;
    }
  }
</style>
