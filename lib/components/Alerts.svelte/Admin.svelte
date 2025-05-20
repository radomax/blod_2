<script>
  import { onMount } from "svelte";
  import {
    bpRecords,
    currentUser,
    categorizeBP,
    formatDate,
    formatTime,
    showAlert,
  } from "$lib/stores";
  import { getMeasurements, deleteMeasurement } from "$lib/api";

  let searchTerm = "";
  let records = [];
  let isLoading = false;
  let isSearching = false;

  onMount(() => {
    loadRecords();
  });

  async function loadRecords() {
    isLoading = true;

    try {
      const result = await getMeasurements({ limit: 100 });
      if (result.success) {
        records = result.data;
        bpRecords.set(result.data);
      } else {
        // Fallback to local data
        bpRecords.subscribe((localRecords) => {
          records = localRecords;
        })();
      }
    } catch (error) {
      console.error("Error loading records:", error);
      // Use local data as fallback
      bpRecords.subscribe((localRecords) => {
        records = localRecords;
      })();
    } finally {
      isLoading = false;
    }
  }

  function searchRecords() {
    if (!searchTerm.trim()) {
      // Reset to all records if search is empty
      bpRecords.subscribe((allRecords) => {
        records = allRecords;
      })();
      return;
    }

    isSearching = true;

    // Filter records based on search term
    const filtered = records.filter(
      (record) =>
        record.patientId.toLowerCase().includes(searchTerm.toLowerCase()) ||
        record.measurementDate.includes(searchTerm) ||
        (record.notes &&
          record.notes.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    records = filtered;
    isSearching = false;
  }

  async function deleteRecord(recordId) {
    if (!confirm("Er du sikker på at du vil slette denne registreringen?")) {
      return;
    }

    try {
      const result = await deleteMeasurement(recordId);

      if (result.success) {
        // Remove from local array
        records = records.filter((r) => r.id !== recordId);
        bpRecords.update((allRecords) =>
          allRecords.filter((r) => r.id !== recordId)
        );
        showAlert("Registrering slettet", "success");
      } else {
        throw new Error(result.message || "Delete failed");
      }
    } catch (error) {
      console.error("Delete error:", error);

      // Fallback: remove locally anyway
      records = records.filter((r) => r.id !== recordId);
      bpRecords.update((allRecords) =>
        allRecords.filter((r) => r.id !== recordId)
      );
      showAlert(
        "Registrering slettet lokalt (kunne ikke synkronisere med database)",
        "warning"
      );
    }
  }

  function viewRecord(record) {
    const referralLabels = {
      maja: "Maja.no",
      self: "Eget initiativ",
      doctor: "Lege",
      other: "Annet",
    };

    const category = categorizeBP(record.averageSys, record.averageDia);

    const details = [
      `Pasient ID: ${record.patientId}`,
      `Alder: ${record.patientAge || "Ikke oppgitt"}`,
      `Kjønn: ${record.patientGender || "Ikke oppgitt"}`,
      `Blodtrykk: ${record.averageSys}/${record.averageDia} mmHg`,
      `Kategori: ${category.label}`,
      `Dato: ${formatDate(record.measurementDate)} ${formatTime(record.measurementTime)}`,
      `Kilde: ${referralLabels[record.referralSource] || record.referralSource}`,
      `Utstyr: ${record.equipment}`,
      `Mansjett: ${record.cuffSize}`,
      `Arm: ${record.armUsed === "left" ? "Venstre" : "Høyre"}`,
      `Målinger: ${record.measurement1Sys || "N/A"}/${record.measurement1Dia || "N/A"}, ${record.measurement2Sys}/${record.measurement2Dia}, ${record.measurement3Sys}/${record.measurement3Dia}`,
      `Notater: ${record.notes || "Ingen"}`,
      `Registrert av: ${record.registeredBy || "Ukjent"}`,
    ].join("\n");

    alert(details);
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

  function handleKeydown(event) {
    if (event.key === "Enter") {
      searchRecords();
    }
  }
</script>

<section class="admin-section">
  <h1>Administrer målinger</h1>
  <p>Oversikt over alle registrerte blodtrykksmålinger.</p>

  <div class="card">
    <div class="search-controls">
      <div class="search-group">
        <input
          type="text"
          placeholder="Søk på pasient-ID, dato eller notater..."
          bind:value={searchTerm}
          on:keydown={handleKeydown}
        />
        <button
          class="btn btn-primary"
          on:click={searchRecords}
          disabled={isSearching}
        >
          {isSearching ? "Søker..." : "Søk"}
        </button>
        <button
          class="btn btn-secondary"
          on:click={loadRecords}
          disabled={isLoading}
        >
          {isLoading ? "Laster..." : "Oppdater"}
        </button>
      </div>
    </div>

    {#if isLoading}
      <div class="loading">Laster registreringer...</div>
    {:else if records.length === 0}
      <div class="no-records">
        {searchTerm
          ? "Ingen registreringer funnet for søket"
          : "Ingen registreringer funnet"}
      </div>
    {:else}
      <div class="table-responsive">
        <table class="records-table">
          <thead>
            <tr>
              <th>Dato/Tid</th>
              <th>Pasient ID</th>
              <th>Alder</th>
              <th>Blodtrykk</th>
              <th>Kategori</th>
              <th>Kilde</th>
              <th>Registrert av</th>
              <th>Handlinger</th>
            </tr>
          </thead>
          <tbody>
            {#each records as record (record.id)}
              {@const category = categorizeBP(
                record.averageSys,
                record.averageDia
              )}
              <tr>
                <td>
                  <div class="datetime-cell">
                    <div>{formatDate(record.measurementDate)}</div>
                    <div class="time">{formatTime(record.measurementTime)}</div>
                  </div>
                </td>
                <td class="patient-id">{record.patientId}</td>
                <td>{record.patientAge || "-"}</td>
                <td class="bp-reading">
                  {record.averageSys}/{record.averageDia}
                  <small>mmHg</small>
                </td>
                <td>
                  <span class="pressure-status {category.class}">
                    {category.label}
                  </span>
                </td>
                <td>{getReferralSourceLabel(record.referralSource)}</td>
                <td>{record.registeredBy || "Ukjent"}</td>
                <td>
                  <div class="action-buttons">
                    <button
                      class="btn btn-sm btn-info"
                      on:click={() => viewRecord(record)}
                      title="Vis detaljer"
                    >
                      Vis
                    </button>
                    <button
                      class="btn btn-sm btn-danger"
                      on:click={() => deleteRecord(record.id)}
                      title="Slett registrering"
                    >
                      Slett
                    </button>
                  </div>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>

      <div class="table-footer">
        <p>Viser {records.length} registreringer</p>
      </div>
    {/if}
  </div>
</section>

<style>
  .admin-section {
    max-width: 1400px;
    margin: 0 auto;
    padding: 2rem;
  }

  .card {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 2rem;
  }

  .search-controls {
    margin-bottom: 2rem;
  }

  .search-group {
    display: flex;
    gap: 1rem;
    align-items: center;
    flex-wrap: wrap;
  }

  .search-group input {
    flex: 1;
    min-width: 250px;
    padding: 0.75rem;
    border: 1px solid #ced4da;
    border-radius: 4px;
    font-size: 1rem;
  }

  .search-group input:focus {
    outline: none;
    border-color: #80bdff;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  }

  .btn {
    padding: 0.75rem 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.2s;
    white-space: nowrap;
  }

  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .btn-primary {
    background-color: #007bff;
    color: white;
  }

  .btn-primary:hover:not(:disabled) {
    background-color: #0056b3;
  }

  .btn-secondary {
    background-color: #6c757d;
    color: white;
  }

  .btn-secondary:hover:not(:disabled) {
    background-color: #545b62;
  }

  .btn-sm {
    padding: 0.375rem 0.75rem;
    font-size: 0.875rem;
  }

  .btn-info {
    background-color: #17a2b8;
    color: white;
  }

  .btn-info:hover {
    background-color: #138496;
  }

  .btn-danger {
    background-color: #dc3545;
    color: white;
  }

  .btn-danger:hover {
    background-color: #c82333;
  }

  .loading,
  .no-records {
    text-align: center;
    padding: 3rem;
    color: #6c757d;
    font-style: italic;
  }

  .table-responsive {
    overflow-x: auto;
  }

  .records-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1rem;
  }

  .records-table th,
  .records-table td {
    padding: 0.75rem;
    text-align: left;
    border-bottom: 1px solid #e9ecef;
    vertical-align: top;
  }

  .records-table th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
    white-space: nowrap;
  }

  .records-table tr:hover {
    background-color: #f8f9fa;
  }

  .datetime-cell {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .time {
    font-size: 0.75rem;
    color: #6c757d;
  }

  .patient-id {
    font-weight: 500;
  }

  .bp-reading {
    font-weight: 500;
  }

  .bp-reading small {
    color: #6c757d;
    font-weight: normal;
  }

  .pressure-status {
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-weight: 500;
    font-size: 0.75rem;
    white-space: nowrap;
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
    gap: 0.5rem;
    flex-wrap: wrap;
  }

  .table-footer {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid #e9ecef;
    color: #6c757d;
    font-size: 0.875rem;
  }

  @media (max-width: 768px) {
    .search-group {
      flex-direction: column;
      align-items: stretch;
    }

    .search-group input {
      min-width: auto;
    }

    .records-table {
      font-size: 0.875rem;
    }

    .records-table th,
    .records-table td {
      padding: 0.5rem;
    }

    .action-buttons {
      flex-direction: column;
    }
  }
</style>
