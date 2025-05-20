<script>
  import { bpRecords, formatDate, showAlert } from "$lib/stores";
  import { getMeasurements } from "$lib/api";

  let exportFromDate = "";
  let exportToDate = "";
  let exportFormat = "csv";
  let isExporting = false;

  // Set default dates (last 30 days)
  const today = new Date();
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(today.getDate() - 30);

  exportToDate = today.toISOString().split("T")[0];
  exportFromDate = thirtyDaysAgo.toISOString().split("T")[0];

  async function handleExport() {
    isExporting = true;

    try {
      // Get filtered records
      let records = [];

      // Try to get from API first
      try {
        const result = await getMeasurements({
          fromDate: exportFromDate,
          toDate: exportToDate,
        });

        if (result.success) {
          records = result.data;
        }
      } catch (error) {
        console.warn("API not available, using local data");
        // Fallback to local data
        bpRecords.subscribe((localRecords) => {
          records = localRecords;
        })();
      }

      // Apply date filters to local data if API didn't handle it
      if (exportFromDate) {
        records = records.filter(
          (record) => record.measurementDate >= exportFromDate
        );
      }
      if (exportToDate) {
        records = records.filter(
          (record) => record.measurementDate <= exportToDate
        );
      }

      if (records.length === 0) {
        showAlert("Ingen registreringer funnet for valgt periode", "warning");
        return;
      }

      // Generate export data
      let exportData;
      let mimeType;
      let fileExtension;

      if (exportFormat === "csv") {
        exportData = generateCSV(records);
        mimeType = "text/csv";
        fileExtension = "csv";
      } else if (exportFormat === "json") {
        exportData = JSON.stringify(records, null, 2);
        mimeType = "application/json";
        fileExtension = "json";
      } else {
        // excel
        exportData = generateCSV(records);
        mimeType = "text/csv";
        fileExtension = "csv";
      }

      // Create and download file
      downloadFile(exportData, mimeType, fileExtension);
      showAlert(
        `Eksport fullført! ${records.length} registreringer lastet ned.`,
        "success"
      );
    } catch (error) {
      console.error("Export error:", error);
      showAlert("Feil ved eksport av data", "error");
    } finally {
      isExporting = false;
    }
  }

  function generateCSV(records) {
    const headers = [
      "Pasient ID",
      "Alder",
      "Kjønn",
      "Dato",
      "Tid",
      "Kilde",
      "Måling 1 Sys",
      "Måling 1 Dia",
      "Måling 2 Sys",
      "Måling 2 Dia",
      "Måling 3 Sys",
      "Måling 3 Dia",
      "Gjennomsnitt Sys",
      "Gjennomsnitt Dia",
      "Utstyr",
      "Mansjett",
      "Arm",
      "Notater",
      "Registrert av",
      "Registrert",
    ];

    const rows = records.map((record) => [
      record.patientId || "",
      record.patientAge || "",
      record.patientGender || "",
      record.measurementDate || "",
      record.measurementTime || "",
      record.referralSource || "",
      record.measurement1Sys || "",
      record.measurement1Dia || "",
      record.measurement2Sys || "",
      record.measurement2Dia || "",
      record.measurement3Sys || "",
      record.measurement3Dia || "",
      record.averageSys || "",
      record.averageDia || "",
      record.equipment || "",
      record.cuffSize || "",
      record.armUsed || "",
      record.notes || "",
      record.registeredBy || "",
      record.registeredAt || "",
    ]);

    return [headers, ...rows]
      .map((row) =>
        row.map((field) => `"${String(field).replace(/"/g, '""')}"`).join(",")
      )
      .join("\n");
  }

  function downloadFile(data, mimeType, extension) {
    const blob = new Blob([data], { type: mimeType });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `blodtrykksmaalinger-${new Date().toISOString().split("T")[0]}.${extension}`;
    link.click();
    window.URL.revokeObjectURL(url);
  }

  function getEstimatedRecordCount() {
    let count = 0;
    bpRecords.subscribe((records) => {
      let filteredRecords = records;

      if (exportFromDate) {
        filteredRecords = filteredRecords.filter(
          (record) => record.measurementDate >= exportFromDate
        );
      }
      if (exportToDate) {
        filteredRecords = filteredRecords.filter(
          (record) => record.measurementDate <= exportToDate
        );
      }

      count = filteredRecords.length;
    })();

    return count;
  }
</script>

<section class="export-section">
  <h1>Eksporter data</h1>
  <p>Eksporter blodtrykksmålinger for analyse eller rapportering.</p>

  <div class="card">
    <h2>Filtrer data for eksport</h2>
    <form on:submit|preventDefault={handleExport}>
      <div class="input-group">
        <div class="form-group">
          <label for="exportFromDate">Fra dato</label>
          <input type="date" id="exportFromDate" bind:value={exportFromDate} />
        </div>
        <div class="form-group">
          <label for="exportToDate">Til dato</label>
          <input type="date" id="exportToDate" bind:value={exportToDate} />
        </div>
      </div>

      <div class="form-group">
        <label for="exportFormat">Eksportformat</label>
        <select id="exportFormat" bind:value={exportFormat}>
          <option value="csv">CSV</option>
          <option value="json">JSON</option>
          <option value="excel">Excel (CSV)</option>
        </select>
      </div>

      <div class="export-preview">
        <p>
          <strong>Estimert antall registreringer:</strong>
          {getEstimatedRecordCount()}
        </p>
        <p class="text-muted">
          Eksporterer registreringer fra {exportFromDate || "start"} til {exportToDate ||
            "slutt"}
        </p>
      </div>

      <div class="form-group">
        <button type="submit" class="btn btn-primary" disabled={isExporting}>
          {isExporting ? "Eksporterer..." : "Eksporter data"}
        </button>
      </div>
    </form>
  </div>

  <div class="card">
    <h2>Eksportinformasjon</h2>
    <div class="export-info">
      <div class="info-item">
        <h4>CSV-format</h4>
        <p>
          Kommaseparerte verdier som kan åpnes i Excel, Google Sheets eller
          andre regnearkprogrammer.
        </p>
      </div>
      <div class="info-item">
        <h4>JSON-format</h4>
        <p>
          Strukturert dataformat som kan brukes til videre analyse eller import
          i andre systemer.
        </p>
      </div>
      <div class="info-item">
        <h4>Inkluderte felt</h4>
        <ul>
          <li>Pasientinformasjon (ID, alder, kjønn)</li>
          <li>Måledata (alle 3 målinger + gjennomsnitt)</li>
          <li>Måleutstyr og metode</li>
          <li>Registreringsdata</li>
          <li>Eventuelle notater</li>
        </ul>
      </div>
    </div>
  </div>

  <div class="card">
    <h2>Personvern og sikkerhet</h2>
    <div class="privacy-notice">
      <p>
        <strong>Viktig:</strong> De eksporterte dataene inneholder personopplysninger
        og må behandles i henhold til gjeldende personvernregler.
      </p>
      <ul>
        <li>Lagre eksporterte filer sikkert</li>
        <li>Del ikke data med unauthorized personer</li>
        <li>Slett filer når de ikke lenger er nødvendige</li>
        <li>Anonymiser data ved deling til forskningsformål</li>
      </ul>
    </div>
  </div>
</section>

<style>
  .export-section {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
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

  .form-group {
    margin-bottom: 1.5rem;
  }

  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #495057;
  }

  .form-group input,
  .form-group select {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ced4da;
    border-radius: 4px;
    font-size: 1rem;
  }

  .form-group input:focus,
  .form-group select:focus {
    outline: none;
    border-color: #80bdff;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  }

  .input-group {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }

  .export-preview {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 4px;
    margin-bottom: 1rem;
  }

  .text-muted {
    color: #6c757d;
    font-size: 0.875rem;
  }

  .btn {
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.2s;
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

  .export-info {
    display: grid;
    gap: 1.5rem;
  }

  .info-item h4 {
    margin-bottom: 0.5rem;
    color: #495057;
  }

  .info-item p {
    margin-bottom: 0.5rem;
    color: #6c757d;
  }

  .info-item ul {
    padding-left: 1.5rem;
    color: #6c757d;
  }

  .info-item li {
    margin-bottom: 0.25rem;
  }

  .privacy-notice {
    background: #fff3cd;
    padding: 1.5rem;
    border-radius: 4px;
    border: 1px solid #ffeaa7;
  }

  .privacy-notice p {
    margin-bottom: 1rem;
    color: #856404;
  }

  .privacy-notice ul {
    padding-left: 1.5rem;
    color: #856404;
  }

  .privacy-notice li {
    margin-bottom: 0.5rem;
  }

  @media (max-width: 768px) {
    .input-group {
      grid-template-columns: 1fr;
    }
  }
</style>
