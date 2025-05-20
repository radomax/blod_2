<script>
  import { onMount } from "svelte";
  import { saveMeasurement } from "$lib/api";
  import { bpRecords, categorizeBP, showAlert } from "$lib/stores";

  let form;
  let isSubmitting = false;

  // Measurement values
  let measurement1Sys = "";
  let measurement1Dia = "";
  let measurement2Sys = "";
  let measurement2Dia = "";
  let measurement3Sys = "";
  let measurement3Dia = "";

  // Patient info
  let patientAge = "";
  let patientGender = "";
  let patientId = "";
  let referralSource = "";

  // Measurement info
  let measurementDate = "";
  let measurementTime = "";
  let equipment = "microlife-b2";
  let cuffSize = "M/L";
  let armUsed = "";
  let notes = "";

  // Average calculation
  let averageResult = null;

  $: {
    if (
      measurement2Sys &&
      measurement2Dia &&
      measurement3Sys &&
      measurement3Dia
    ) {
      const avgSys = Math.round(
        (parseInt(measurement2Sys) + parseInt(measurement3Sys)) / 2
      );
      const avgDia = Math.round(
        (parseInt(measurement2Dia) + parseInt(measurement3Dia)) / 2
      );
      const category = categorizeBP(avgSys, avgDia);

      averageResult = {
        sys: avgSys,
        dia: avgDia,
        category,
      };
    } else {
      averageResult = null;
    }
  }

  onMount(() => {
    // Set today's date and current time as defaults
    const now = new Date();
    measurementDate = now.toISOString().split("T")[0];
    measurementTime = now.toLocaleTimeString("en-GB", {
      hour: "2-digit",
      minute: "2-digit",
    });
  });

  function validateForm() {
    const required = [
      { value: measurement2Sys, name: "Måling 2 - Systolisk" },
      { value: measurement2Dia, name: "Måling 2 - Diastolisk" },
      { value: measurement3Sys, name: "Måling 3 - Systolisk" },
      { value: measurement3Dia, name: "Måling 3 - Diastolisk" },
      { value: armUsed, name: "Arm brukt for måling" },
    ];

    for (const field of required) {
      if (!field.value) {
        showAlert(`Mangler påkrevd felt: ${field.name}`, "error");
        return false;
      }
    }

    // Validate blood pressure ranges
    const sys2 = parseInt(measurement2Sys);
    const dia2 = parseInt(measurement2Dia);
    const sys3 = parseInt(measurement3Sys);
    const dia3 = parseInt(measurement3Dia);

    if (sys2 < 70 || sys2 > 250 || sys3 < 70 || sys3 > 250) {
      showAlert("Systolisk blodtrykk må være mellom 70 og 250 mmHg", "error");
      return false;
    }

    if (dia2 < 40 || dia2 > 150 || dia3 < 40 || dia3 > 150) {
      showAlert("Diastolisk blodtrykk må være mellom 40 og 150 mmHg", "error");
      return false;
    }

    return true;
  }

  async function handleSubmit(event) {
    event.preventDefault();

    if (!validateForm()) {
      return;
    }

    isSubmitting = true;

    const formData = {
      patientId: patientId || "Ukjent",
      patientAge: parseInt(patientAge) || 0,
      patientGender: patientGender || "other",
      measurementDate,
      measurementTime,
      referralSource: referralSource || "other",
      measurement1Sys: measurement1Sys ? parseInt(measurement1Sys) : null,
      measurement1Dia: measurement1Dia ? parseInt(measurement1Dia) : null,
      measurement2Sys: parseInt(measurement2Sys),
      measurement2Dia: parseInt(measurement2Dia),
      measurement3Sys: parseInt(measurement3Sys),
      measurement3Dia: parseInt(measurement3Dia),
      averageSys: averageResult.sys,
      averageDia: averageResult.dia,
      equipment,
      cuffSize,
      armUsed,
      notes: notes || null,
    };

    try {
      const result = await saveMeasurement(formData);

      if (result.success) {
        // Add to local records for immediate UI update
        const newRecord = {
          id: result.data.id,
          ...formData,
          registeredAt: new Date().toISOString(),
          registeredBy: "Current User",
        };

        bpRecords.update((records) => [newRecord, ...records]);
        showAlert("Blodtrykksmåling lagret", "success");
        resetForm();
      } else {
        throw new Error(result.message || "Database error");
      }
    } catch (error) {
      console.error("Save error:", error);
      showAlert("Feil ved lagring av måling. Prøv igjen senere.", "error");
    } finally {
      isSubmitting = false;
    }
  }

  function resetForm() {
    form.reset();
    measurement1Sys = "";
    measurement1Dia = "";
    measurement2Sys = "";
    measurement2Dia = "";
    measurement3Sys = "";
    measurement3Dia = "";
    patientAge = "";
    patientGender = "";
    patientId = "";
    referralSource = "";
    equipment = "microlife-b2";
    cuffSize = "M/L";
    armUsed = "";
    notes = "";

    const now = new Date();
    measurementDate = now.toISOString().split("T")[0];
    measurementTime = now.toLocaleTimeString("en-GB", {
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  function getRecommendation(categoryKey) {
    const recommendations = {
      normal: "Normalt blodtrykk. Fortsett med sunt livsstil.",
      highNormal: "Høyt normalt blodtrykk. Vurder livsstilsendringer.",
      high: "Forhøyet blodtrykk. Det anbefales å konsultere lege.",
      veryHigh:
        "Alvorlig forhøyet blodtrykk. Kontakt lege/legevakt umiddelbart.",
    };
    return recommendations[categoryKey];
  }
</script>

<section class="registration-section">
  <h1>Registrering av blodtrykksmålinger</h1>
  <p>Registrer blodtrykksmålinger i henhold til prosedyre for apotek.</p>

  <div class="measurement-steps">
    <h4>Viktige punkter før måling:</h4>
    <ol>
      <li>
        Minst 30 minutter siden kunden spiste, drakk kaffe, røykte eller var
        fysisk aktiv
      </li>
      <li>Kunden sitter stille i minimum 5 minutter før første måling</li>
      <li>Utfør totalt 3 målinger med 1 minutts mellomrom</li>
      <li>Rapporter gjennomsnittet av måling 2 og 3</li>
    </ol>
  </div>

  <div class="card">
    <form bind:this={form} on:submit={handleSubmit}>
      <div class="form-group">
        <h3>a. Blodtrykksverdien (snitt av de to siste målingene).</h3>

        <div class="input-group">
          <div class="form-group">
            <label for="measurement1Sys">Måling 1 - Systolisk</label>
            <input
              type="number"
              id="measurement1Sys"
              bind:value={measurement1Sys}
              min="70"
              max="250"
              placeholder="mmHg"
            />
          </div>
          <div class="form-group">
            <label for="measurement1Dia">Måling 1 - Diastolisk</label>
            <input
              type="number"
              id="measurement1Dia"
              bind:value={measurement1Dia}
              min="40"
              max="150"
              placeholder="mmHg"
            />
          </div>
        </div>

        <div class="input-group">
          <div class="form-group">
            <label for="measurement2Sys">Måling 2 - Systolisk</label>
            <input
              type="number"
              id="measurement2Sys"
              bind:value={measurement2Sys}
              min="70"
              max="250"
              placeholder="mmHg"
              required
            />
          </div>
          <div class="form-group">
            <label for="measurement2Dia">Måling 2 - Diastolisk</label>
            <input
              type="number"
              id="measurement2Dia"
              bind:value={measurement2Dia}
              min="40"
              max="150"
              placeholder="mmHg"
              required
            />
          </div>
        </div>

        <div class="input-group">
          <div class="form-group">
            <label for="measurement3Sys">Måling 3 - Systolisk</label>
            <input
              type="number"
              id="measurement3Sys"
              bind:value={measurement3Sys}
              min="70"
              max="250"
              placeholder="mmHg"
              required
            />
          </div>
          <div class="form-group">
            <label for="measurement3Dia">Måling 3 - Diastolisk</label>
            <input
              type="number"
              id="measurement3Dia"
              bind:value={measurement3Dia}
              min="40"
              max="150"
              placeholder="mmHg"
              required
            />
          </div>
        </div>

        {#if averageResult}
          <div class="measurement-history">
            <h4>Gjennomsnitt (måling 2 og 3):</h4>
            <div class="average-display">
              <strong>{averageResult.sys}/{averageResult.dia} mmHg</strong>
            </div>
            <div class="pressure-category">
              <span class="pressure-status {averageResult.category.class}">
                {averageResult.category.label}
              </span>
              <p style="margin-top: 10px; font-style: italic;">
                {getRecommendation(averageResult.category.key)}
              </p>
            </div>
          </div>
        {/if}
      </div>

      <div class="form-group">
        <h3>b. Arm brukt for måling</h3>
        <select bind:value={armUsed} required>
          <option value="">Velg venstre eller høyre arm</option>
          <option value="left">Venstre</option>
          <option value="right">Høyre</option>
        </select>
      </div>

      <div class="form-group">
        <h3>c. Mansjettstørrelse</h3>
        <select bind:value={cuffSize}>
          <option value="S">S (17-22 cm)</option>
          <option value="M/L">M/L (22-42 cm)</option>
          <option value="L/XL">L/XL (32-52 cm)</option>
        </select>
      </div>

      <div class="form-group">
        <h3>d. Tilleggsnotater</h3>
        <textarea
          bind:value={notes}
          rows="3"
          placeholder="Eventuelle observasjoner eller kommentarer"
        ></textarea>
      </div>

      <hr />

      <div class="form-group">
        <h2>Pasient- og utstyrinformasjon</h2>
        <div class="input-group">
          <div class="form-group">
            <label for="patientAge">Alder</label>
            <input
              type="number"
              id="patientAge"
              bind:value={patientAge}
              min="0"
              max="130"
            />
          </div>
          <div class="form-group">
            <label for="patientGender">Kjønn</label>
            <select id="patientGender" bind:value={patientGender}>
              <option value="">Velg</option>
              <option value="male">Mann</option>
              <option value="female">Kvinne</option>
              <option value="other">Annet</option>
            </select>
          </div>
          <div class="form-group">
            <label for="referralSource">Henvendelse fra</label>
            <select id="referralSource" bind:value={referralSource}>
              <option value="">Velg</option>
              <option value="maja">Maja.no</option>
              <option value="self">Eget initiativ</option>
              <option value="doctor">Lege</option>
              <option value="other">Annet</option>
            </select>
          </div>
          <div class="form-group">
            <label for="patientId">Området:</label>
            <input type="text" id="patientId" bind:value={patientId} />
          </div>
          <div class="form-group">
            <label for="equipment">Blodtrykksapparat</label>
            <select id="equipment" bind:value={equipment}>
              <option value="microlife-b2">Microlife B2 Basic</option>
              <option value="microlife-b6">Microlife B6 Connect</option>
              <option value="llp-bt">LLP BT-måler 22-42 cm</option>
            </select>
          </div>
        </div>
      </div>

      <div class="form-group">
        <h2>Målinginformasjon</h2>
        <div class="input-group">
          <div class="form-group">
            <label for="measurementDate">Målingsdato</label>
            <input
              type="date"
              id="measurementDate"
              bind:value={measurementDate}
              required
            />
          </div>
          <div class="form-group">
            <label for="measurementTime">Tidspunkt</label>
            <input
              type="time"
              id="measurementTime"
              bind:value={measurementTime}
              required
            />
          </div>
        </div>
      </div>

      <div class="form-group">
        <button type="submit" class="btn btn-success" disabled={isSubmitting}>
          {isSubmitting ? "Lagrer..." : "Lagre måling"}
        </button>
        <button type="button" class="btn btn-secondary" on:click={resetForm}>
          Nullstill skjema
        </button>
      </div>
    </form>
  </div>
</section>

<style>
  .registration-section {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
  }

  .card {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 2rem;
    margin-top: 1rem;
  }

  .measurement-steps {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 2rem;
  }

  .measurement-steps h4 {
    margin-bottom: 1rem;
    color: #495057;
  }

  .measurement-steps ol {
    padding-left: 1.5rem;
  }

  .measurement-steps li {
    margin-bottom: 0.5rem;
  }

  .form-group {
    margin-bottom: 1.5rem;
  }

  .form-group h2,
  .form-group h3 {
    margin-bottom: 1rem;
    color: #495057;
  }

  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #495057;
  }

  .form-group input,
  .form-group select,
  .form-group textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ced4da;
    border-radius: 4px;
    font-size: 1rem;
  }

  .form-group input:focus,
  .form-group select:focus,
  .form-group textarea:focus {
    outline: none;
    border-color: #80bdff;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  }

  .input-group {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }

  .measurement-history {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 8px;
    margin-top: 1rem;
  }

  .average-display {
    font-size: 1.5rem;
    margin-bottom: 0.5rem;
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

  .btn {
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
    margin-right: 0.5rem;
    transition: background-color 0.2s;
  }

  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .btn-success {
    background-color: #28a745;
    color: white;
  }

  .btn-success:hover:not(:disabled) {
    background-color: #218838;
  }

  .btn-secondary {
    background-color: #6c757d;
    color: white;
  }

  .btn-secondary:hover {
    background-color: #545b62;
  }

  hr {
    border: none;
    border-top: 1px solid #e9ecef;
    margin: 2rem 0;
  }
</style>
