;; BountyHub - Decentralized Community Bounty Board
;; Version: v1.0
;; Description: A decentralized bounty posting and fulfillment system.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS & ERRORS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR-NOT-CREATOR (err u100))
(define-constant ERR-NOT-CLAIMANT (err u101))
(define-constant ERR-BOUNTY-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-CLAIMED (err u103))
(define-constant ERR-NOT-SUBMITTED (err u104))
(define-constant ERR-ALREADY-COMPLETED (err u105))
(define-constant ERR-DEADLINE-PASSED (err u106))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA STRUCTURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var bounty-counter uint u0)

(define-map bounties
  {id: uint}
  {
    creator: principal,
    title: (string-ascii 48),
    description: (string-ascii 140),
    reward: uint,
    deadline: uint,
    status: (string-ascii 16), ;; "open", "claimed", "submitted", "completed", "cancelled"
    claimer: (optional principal),
    submission: (optional (string-ascii 140))
  }
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CREATE & FUND BOUNTIES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (create-bounty (title (string-ascii 48)) (description (string-ascii 140)) (reward uint) (duration uint))
  (begin
    (asserts! (> reward u0) (err u400))
    (let ((id (+ (var-get bounty-counter) u1)))
      (begin
        (map-set bounties {id: id}
          {
            creator: tx-sender,
            title: title,
            description: description,
            reward: reward,
            deadline: (+ stacks-block-height duration),
            status: "open            ",
            claimer: none,
            submission: none
          })
        (var-set bounty-counter id)
        (print {event: "bounty-created", id: id, creator: tx-sender})
        (ok id)
      )
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CLAIM, SUBMIT, APPROVE & CANCEL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (claim-bounty (id uint))
  (let ((bounty (unwrap! (map-get? bounties {id: id}) ERR-BOUNTY-NOT-FOUND)))
    (begin
      (asserts! (is-eq (get status bounty) "open            ") ERR-ALREADY-CLAIMED)
      (asserts! (< stacks-block-height (get deadline bounty)) ERR-DEADLINE-PASSED)
      (map-set bounties {id: id}
        (merge bounty {claimer: (some tx-sender), status: "claimed         "}))
      (print {event: "bounty-claimed", id: id, claimer: tx-sender})
      (ok true)
    )
  )
)

(define-public (submit-work (id uint) (submission (string-ascii 140)))
  (let ((bounty (unwrap! (map-get? bounties {id: id}) ERR-BOUNTY-NOT-FOUND)))
    (begin
      (asserts! (is-some (get claimer bounty)) ERR-NOT-CLAIMANT)
      (asserts! (is-eq tx-sender (unwrap-panic (get claimer bounty))) ERR-NOT-CLAIMANT)
      (asserts! (is-eq (get status bounty) "claimed         ") ERR-NOT-SUBMITTED)
      (map-set bounties {id: id}
        (merge bounty {submission: (some submission), status: "submitted       "}))
      (print {event: "work-submitted", id: id, claimer: tx-sender})
      (ok true)
    )
  )
)

(define-public (approve-work (id uint))
  (let ((bounty (unwrap! (map-get? bounties {id: id}) ERR-BOUNTY-NOT-FOUND)))
    (begin
      (asserts! (is-eq tx-sender (get creator bounty)) ERR-NOT-CREATOR)
      (asserts! (is-eq (get status bounty) "submitted       ") ERR-NOT-SUBMITTED)
      (let ((claimer (unwrap-panic (get claimer bounty))))
        (try! (stx-transfer? (get reward bounty) tx-sender claimer))
        (map-set bounties {id: id} (merge bounty {status: "completed       "}))
        (print {event: "bounty-completed", id: id, claimer: claimer})
        (ok true)
      )
    )
  )
)

(define-public (cancel-bounty (id uint))
  (let ((bounty (unwrap! (map-get? bounties {id: id}) ERR-BOUNTY-NOT-FOUND)))
    (begin
      (asserts! (is-eq tx-sender (get creator bounty)) ERR-NOT-CREATOR)
      (asserts! (is-eq (get status bounty) "open            ") ERR-ALREADY-COMPLETED)
      (map-set bounties {id: id} (merge bounty {status: "cancelled       "}))
      (print {event: "bounty-cancelled", id: id})
      (ok true)
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READ-ONLY FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-bounty (id uint))
  (map-get? bounties {id: id})
)

;; Fixed map-get to map-get? for optional return
(define-read-only (is-claimed (id uint))
  (let ((b (map-get? bounties {id: id})))
    (if (is-some b)
        (ok (is-some (get claimer (unwrap-panic b))))
        (err u404)
    )
  )
)

(define-read-only (get-total-bounties)
  (var-get bounty-counter)
)
