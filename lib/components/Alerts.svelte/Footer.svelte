<footer class="site-footer">
  <div class="container">
    <div class="footer-content">
      <div class="footer-section">
        <h3>Om blodtrykksmålinger</h3>
        <p>
          Dette systemet støtter registrering av blodtrykksmålinger i apotek i
          henhold til gjeldende prosedyrer og retningslinjer.
        </p>
      </div>
      <div class="footer-section">
        <h3>Nyttige lenker</h3>
        <ul class="footer-links">
          <li>
            <a
              href="https://helsedirektoratet.no"
              target="_blank"
              rel="noopener noreferrer">Helsedirektoratet</a
            >
          </li>
          <li>
            <a href="https://maja.no" target="_blank" rel="noopener noreferrer"
              >Maja.no</a
            >
          </li>
          <li>
            <a href="#" on:click|preventDefault={() => {}}
              >Prosedyrer og retningslinjer</a
            >
          </li>
        </ul>
      </div>
      <div class="footer-section">
        <h3>Kontakt</h3>
        <p>
          For teknisk støtte eller spørsmål om systemet, bruk kontaktskjemaet i
          applikasjonen.
        </p>
      </div>
    </div>
    <div class="copyright">
      <p>&copy; 2025 Blodtrykksmålinger. Alle rettigheter forbeholdt.</p>
    </div>
  </div>
</footer>

<style>
  .site-footer {
    background-color: #343a40;
    color: #ffffff;
    margin-top: auto;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
  }

  .footer-content {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 2rem;
    padding: 2rem 0;
  }

  .footer-section h3 {
    color: #ffffff;
    margin-bottom: 1rem;
    font-size: 1.125rem;
  }

  .footer-section p {
    color: #ced4da;
    line-height: 1.6;
    margin-bottom: 0;
  }

  .footer-links {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .footer-links li {
    margin-bottom: 0.5rem;
  }

  .footer-links a {
    color: #ced4da;
    text-decoration: none;
    transition: color 0.2s;
  }

  .footer-links a:hover {
    color: #ffffff;
  }

  .copyright {
    border-top: 1px solid #495057;
    padding: 1rem 0;
    text-align: center;
  }

  .copyright p {
    margin: 0;
    color: #ced4da;
    font-size: 0.875rem;
  }

  @media (max-width: 768px) {
    .footer-content {
      grid-template-columns: 1fr;
      text-align: center;
    }
  }
</style>
