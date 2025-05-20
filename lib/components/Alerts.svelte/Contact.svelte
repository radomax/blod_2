<script>
  import { showAlert } from "$lib/stores";

  let contactName = "";
  let contactEmail = "";
  let contactSubject = "";
  let contactMessage = "";
  let isSubmitting = false;

  async function handleSubmit(event) {
    event.preventDefault();

    if (!contactName || !contactEmail || !contactSubject || !contactMessage) {
      showAlert("Vennligst fyll ut alle feltene", "error");
      return;
    }

    isSubmitting = true;

    try {
      // In a real implementation, you would send this to your backend
      // For now, we'll just simulate success
      await new Promise((resolve) => setTimeout(resolve, 1000));

      showAlert(
        "Takk for din henvendelse! Vi vil kontakte deg så snart som mulig.",
        "success"
      );

      // Reset form
      contactName = "";
      contactEmail = "";
      contactSubject = "";
      contactMessage = "";
    } catch (error) {
      console.error("Contact form error:", error);
      showAlert("Feil ved sending av melding. Prøv igjen senere.", "error");
    } finally {
      isSubmitting = false;
    }
  }
</script>

<section class="contact-section">
  <h1>Kontakt oss</h1>
  <p>Spørsmål om blodtrykksmålinger eller teknisk støtte?</p>

  <div class="card">
    <h2>Send oss en melding</h2>
    <form on:submit={handleSubmit}>
      <div class="form-group">
        <label for="contactName">Navn</label>
        <input type="text" id="contactName" bind:value={contactName} required />
      </div>

      <div class="form-group">
        <label for="contactEmail">E-post</label>
        <input
          type="email"
          id="contactEmail"
          bind:value={contactEmail}
          required
        />
      </div>

      <div class="form-group">
        <label for="contactSubject">Emne</label>
        <select id="contactSubject" bind:value={contactSubject} required>
          <option value="">Velg emne</option>
          <option value="measurement">Spørsmål om måling</option>
          <option value="equipment">Utstyr og kalibrering</option>
          <option value="system">Systemspørsmål</option>
          <option value="other">Annet</option>
        </select>
      </div>

      <div class="form-group">
        <label for="contactMessage">Melding</label>
        <textarea
          id="contactMessage"
          bind:value={contactMessage}
          rows="5"
          required
          placeholder="Beskriv ditt spørsmål eller problem..."
        ></textarea>
      </div>

      <div class="form-group">
        <button type="submit" class="btn btn-primary" disabled={isSubmitting}>
          {isSubmitting ? "Sender..." : "Send melding"}
        </button>
      </div>
    </form>
  </div>

  <div class="contact-info-grid">
    <div class="card">
      <h3>Kontaktinformasjon Maja.no</h3>
      <div class="contact-details">
        <div class="contact-item">
          <strong>Vakttelefon:</strong>
          <span>92 117 118</span>
        </div>
        <div class="contact-item">
          <strong>Åpningstider:</strong>
          <span>8-22 mandag-fredag, 10-18 lørdag-søndag</span>
        </div>
        <div class="contact-item">
          <strong>E-post:</strong>
          <span>hei@maja.no</span>
        </div>
        <div class="contact-notice">
          <em>Sensitiv informasjon skal ikke sendes via e-post.</em>
        </div>
      </div>
    </div>

    <div class="card">
      <h3>Teknisk støtte</h3>
      <div class="support-info">
        <p>For tekniske problemer med systemet:</p>
        <ul>
          <li>Bruk kontaktskjemaet over</li>
          <li>Beskriv problemet så detaljert som mulig</li>
          <li>Oppgi nettleser og enhet du bruker</li>
          <li>Inkluder eventuelle feilmeldinger</li>
        </ul>
      </div>
    </div>

    <div class="card">
      <h3>Akutte situasjoner</h3>
      <div class="emergency-info">
        <p><strong>Ved akutte medisinske situasjoner:</strong></p>
        <div class="emergency-numbers">
          <div class="emergency-item">
            <span class="emergency-label">Akuttmedisin:</span>
            <span class="emergency-number">113</span>
          </div>
          <div class="emergency-item">
            <span class="emergency-label">Legevakt:</span>
            <span class="emergency-number">116 117</span>
          </div>
        </div>
        <p>
          <em
            >Dette systemet er kun for registrering og skal ikke erstatte
            medisinsk vurdering.</em
          >
        </p>
      </div>
    </div>
  </div>

  <div class="card">
    <h3>Ofte stilte spørsmål</h3>
    <div class="faq-list">
      <div class="faq-item">
        <h4>Hvordan kalibrerer jeg blodtrykksapparatet?</h4>
        <p>
          Blodtrykksapparatene bør kalibreres minst en gang per år. Kontakt
          leverandøren for kalibrering eller bruk kontaktskjemaet for mer
          informasjon.
        </p>
      </div>
      <div class="faq-item">
        <h4>Hvor lagres målingene?</h4>
        <p>
          Alle målinger lagres sikkert i henhold til personvernregelverket. Data
          kan eksporteres for analyse eller rapportering.
        </p>
      </div>
      <div class="faq-item">
        <h4>Kan jeg endre en registrering?</h4>
        <p>
          Kun administratorer kan redigere eller slette registreringer. Kontakt
          din systemadministrator hvis det er nødvendig.
        </p>
      </div>
    </div>
  </div>
</section>

<style>
  .contact-section {
    max-width: 1000px;
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

  .card h2,
  .card h3 {
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
  .form-group select,
  .form-group textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ced4da;
    border-radius: 4px;
    font-size: 1rem;
    resize: vertical;
  }

  .form-group input:focus,
  .form-group select:focus,
  .form-group textarea:focus {
    outline: none;
    border-color: #80bdff;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
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

  .contact-info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
  }

  .contact-details,
  .support-info,
  .emergency-info {
    line-height: 1.6;
  }

  .contact-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.75rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid #e9ecef;
  }

  .contact-item:last-child {
    border-bottom: none;
    margin-bottom: 1rem;
  }

  .contact-notice {
    background: #f8f9fa;
    padding: 0.75rem;
    border-radius: 4px;
    color: #6c757d;
    font-size: 0.875rem;
  }

  .support-info ul {
    padding-left: 1.5rem;
    color: #6c757d;
  }

  .support-info li {
    margin-bottom: 0.5rem;
  }

  .emergency-numbers {
    margin: 1rem 0;
  }

  .emergency-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem;
    background: #f8d7da;
    border: 1px solid #f5c6cb;
    border-radius: 4px;
    margin-bottom: 0.5rem;
  }

  .emergency-label {
    font-weight: 500;
    color: #721c24;
  }

  .emergency-number {
    font-size: 1.25rem;
    font-weight: bold;
    color: #721c24;
  }

  .emergency-info em {
    color: #6c757d;
    font-size: 0.875rem;
  }

  .faq-list {
    margin-top: 1rem;
  }

  .faq-item {
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e9ecef;
  }

  .faq-item:last-child {
    border-bottom: none;
    margin-bottom: 0;
  }

  .faq-item h4 {
    margin-bottom: 0.5rem;
    color: #495057;
  }

  .faq-item p {
    color: #6c757d;
    line-height: 1.6;
  }

  @media (max-width: 768px) {
    .contact-info-grid {
      grid-template-columns: 1fr;
    }

    .contact-item {
      flex-direction: column;
      gap: 0.25rem;
    }

    .emergency-item {
      flex-direction: column;
      text-align: center;
      gap: 0.5rem;
    }
  }
</style>
