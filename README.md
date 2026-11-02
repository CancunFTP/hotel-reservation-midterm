# Hotel Reservation Management System — Ruby Midterm

This project implements nine Ruby classes: four room types (including abstract `Room`), `ReservationEvent`, `Reservation`, and three notifier classes. The `Notifier` interface is **duck-typed** and therefore has no separate Ruby file. It appears in the UML.

## Prerequisites
- Ruby 3.x
- Bundler and RSpec (for tests)

## Run the demonstration
From the `hotel-reservation` directory:

```bash
ruby bin/demo.rb
```

The demonstration books a three-night suite for Carol, uses all three notifier types, records confirmation and check-in events, and prints the latest status and total cost. It **does not actually send** SMS or email; those classes print simulated notifications.

## Run the test suite

```bash
gem install bundler  # only needed if Bundler is not installed
bundle install
bundle exec rspec
```

If you already have the `rspec` gem installed, you can also run `rspec`.

## Key methods

| Class | Responsibility | Public methods |
| --- | --- | --- |
| `Room` | Shared room information | `description`, `to_s`, abstract `calculate_cost` |
| `StandardRoom`, `SuiteRoom`, `CabanaRoom` | Room-specific pricing | `calculate_cost` |
| `ReservationEvent` | Immutable event data | `to_s`, read-only fields |
| `Reservation` | Coordinate guest, room, events, and notification services | `update_status`, `latest_status`, `current_status`, `event_history`, `total_cost` |
| `TextNotifier` | Simulated SMS | `notify(reservation, event)` |
| `EmailNotifier` | Simulated email | `notify(reservation, event)` |
| `FrontDeskNotifier` | Front desk alert | `notify(reservation, event)` |

`Reservation.new` accepts `guest_name:`, `room:`, `notifiers:`. `update_status` accepts `status:`, `location:`, and optional `timestamp:` and `notes:`.

## Pricing for three nights
- Standard: $80 + 3 × $40 = **$200**
- Suite: $80 + 3 × $40 + $75 = **$275**
- Cabana: ($80 + 3 × $40) × 1.5 = **$300**

Some price examples in the supplied assignment have truncated or garbled text. These calculations use the assignment's explicit constants and formulas.

## Folder structure

```
hotel-reservation/
├── bin/demo.rb
├── lib/
│   ├── rooms/{room,standard_room,suite_room,cabana_room}.rb
│   ├── notifiers/{text_notifier,email_notifier,front_desk_notifier}.rb
│   ├── reservation_event.rb
│   └── reservation.rb
├── spec/{spec_helper,reservation_spec,rooms_and_events_spec,notifiers_spec}.rb
├── uml_diagram.png
├── uml_diagram.dot     # Editable diagram source
├── solid_analysis.docx
├── Gemfile
└── README.md
```

## How it works
1. `Room` stores the room number and nights; subclasses override `calculate_cost`.
2. `Reservation` receives the room and a list of notifiers as constructor dependencies.
3. When `update_status` is called, `Reservation` creates a `ReservationEvent`.
4. The event is saved and every injected notifier is called **in order** with `notify(reservation, event)`.
5. `event_history` returns a protected copy; `latest_status` and `total_cost` report the booking status and delegated room cost.

Reservation events are appended in the order that status changes are recorded. In an ordinary stay, these calls are chronological. The project does not attempt to reorder events if a caller supplies an out-of-order timestamp.

## GitHub submission checklist
- [ ] Open the project, read through the code, and run `ruby bin/demo.rb`.
- [ ] Run `bundle exec rspec` and confirm all examples pass.
- [ ] Review `uml_diagram.png` for all classes and relationships.
- [ ] Read and personalize the reasoning in `solid_analysis.docx` to reflect your own decisions.
- [ ] Initialize a Git repository, commit the project files, and push to GitHub.
- [ ] Submit your **GitHub repository URL**, not just a ZIP file, as specified in the assignment.

## GitHub commands

```bash
git init
git add .
git commit -m "Build hotel reservation midterm project"
git branch -M main
git remote add origin YOUR_GITHUB_REPO_URL
git push -u origin main
```

Create an empty repository first and replace `YOUR_GITHUB_REPO_URL` with its actual GitHub HTTPS or SSH URL.
