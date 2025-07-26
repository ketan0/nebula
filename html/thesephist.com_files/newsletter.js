const {
	Component,
} = window.Torus;

class NewsletterForm extends Component {
	init() {
		this.inputs = {
			givenName: '',
			familyName: '',
			email: '',
		}
		this._sent = false;
		this._error = false;

		this.handleSubmit = this.handleSubmit.bind(this);
		this.handleInput = this.handleInput.bind(this);
	}
	handleSubmit(evt) {
		evt.preventDefault();

		fetch('https://lovecroft.thesephist.com/subscribe/mail.thesephist.com', {
			method: 'POST',
			body: JSON.stringify({...this.inputs}),
		}).then(resp => {
			if (resp.status === 500) {
				this._error = true;
			} else {
				this._sent = true;
			}
		}).catch(e => {
			console.error(e);
			this._error = e;
		}).finally(this.render.bind(this));
	}
	handleInput(evt) {
		this.inputs[evt.target.getAttribute('name')] = evt.target.value;
		this.render();
	}
	compose() {
		if (this._sent) {
			return jdom`<p class="paper paper-border-left">
				Thanks for signing up! You'll hear from me next week.
			</p>`;
		}
		return jdom`<div>
			<p>
				If you want to hear about what I'm building, writing,
				and thinking about each week, you can join my newsletter.
				My last issue is <a href="https://linus.zone/latest">here</a>.
			</p>
			${this._error ? jdom`<p class="paper paper-border-left">
				There was a problem signing up! Please try again.
			</p>` : null}
			<form class="newsletter-form" onsubmit="${this.handleSubmit}">
				<div class="name-slot">
					<div class="slot">
						<label for="newsletter-first-name">First name</label>
						<input id="newsletter-first-name" name="givenName"
							class="paper"
							placeholder="Linus"
							value="${this.inputs.givenName}"
							oninput="${this.handleInput}" />
					</div>

					<div class="slot">
						<label for="newsletter-last-name">Last name</label>
						<input id="newsletter-last-name"  name="familyName"
							class="paper"
							placeholder="Lee"
							value="${this.inputs.familyName}"
							oninput="${this.handleInput}" />
					</div>
				</div>

				<div class="slot extended required">
					<label for="newsletter-email">Email</label>
					<input id="newsletter-email" type="email" name="email"
						required
						class="paper"
						placeholder="linus@example.com"
						value="${this.inputs.email}"
						oninput="${this.handleInput}" />
				</div>

				<button class="movable accent paper submitButton">
					Join <span class="mobile">→</span>
				</button>
			</form>
		</div>
		`;
	}
}

const formAnchor = document.getElementById('newsletter');
const form = new NewsletterForm();
formAnchor.appendChild(form.node);

