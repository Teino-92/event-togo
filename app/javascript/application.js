import "@hotwired/turbo-rails";
import "controllers";
import "@popperjs/core";
import "bootstrap";

// import $ from "jquery";

//  $(function() {

//    Sticky header
//    $(window).scroll(function() {
//      if ($(window).scrollTop() > 100) {
//        $('.main_h').addClass('sticky');
//      } else {
//        $('.main_h').removeClass('sticky');
//      }
//    });

//     Mobile Navigation toggle
//    $('.mobile-toggle').click(function(e) {
//      e.stopPropagation(); // evita che il click chiuda il dropdown
//      $('.main_h').toggleClass('open-nav');
//    });

//    // Chiudi il mobile menu solo se il link NON è dropdown
//    $('.main_h li a').click(function(e) {
// //     if (!$(this).hasClass('dropdown-toggle') && $('.main_h').hasClass('open-nav')) {
// //       $('.main_h').removeClass('open-nav');
// //     }
// //   });

// //   // Smooth scroll per ancore
// //   $('a[href^="#"]').click(function(event) {
// //     var targetId = $(this).attr("href");
// //     if ($(targetId).length) {
// //       var offset = 70;
// //       $('html, body').animate({ scrollTop: $(targetId).offset().top - offset }, 500);
// //       event.preventDefault();
// //     }
// //   });

// //   // Chiudi dropdown cliccando fuori
// //   $(document).click(function(e) {
// //     var target = $(e.target);
// //     if (!target.closest('.dropdown').length) {
// //       $('.dropdown-menu.show').removeClass('show');
// //     }
// //   });

// //   // Attiva dropdown con click manuale (se necessario)
// //   $('.dropdown-toggle').click(function(e) {
// //     e.preventDefault();
// //     var $menu = $(this).siblings('.dropdown-menu');
// //     $menu.toggleClass('show');
// //   });

// // });
