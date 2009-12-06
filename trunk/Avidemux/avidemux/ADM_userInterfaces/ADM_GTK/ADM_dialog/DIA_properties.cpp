/*
 * This file was generated by Glade, once upon a time.
 */
#include <math.h>

#include "ADM_toolkitGtk.h"

#include "avidemutils.h"
#include "ADM_video/ADM_vidMisc.h"

#include "avi_vars.h"
#define FILL_ENTRY(x) gtk_label_set_text((GtkLabel *) lookup_widget(dialog,#x),text);
#define SET_YES(x,y) gtk_label_set_text((GtkLabel *) lookup_widget(dialog,#x),yesno[y])
#define DISABLE_WIDGET(x) gtk_widget_set_sensitive(lookup_widget(dialog,#x), false);

extern const char *getStrFromAudioCodec( uint32_t codec);
static GtkWidget	*create_dialog1 (void);

void DIA_properties( void )
{

 char text[80];
 uint16_t hh, mm, ss, ms;
 GtkWidget *dialog;
 uint8_t gmc, qpel,vop;
 uint32_t info=0;
 const char *yesno[2]={QT_TR_NOOP("No"),QT_TR_NOOP("Yes")};
 uint32_t war,har;

    if (playing)
        return;
  
    text[0] = 0;
    if (!avifileinfo)
        return;
  
        // Fetch info
        info=video_body->getSpecificMpeg4Info();
        vop=!!(info & ADM_VOP_ON);
        qpel=!!(info & ADM_QPEL_ON);
        gmc=!!(info & ADM_GMC_ON);
        
        dialog = create_dialog1();

        gtk_register_dialog(dialog);

        sprintf(text, QT_TR_NOOP("%lu x %lu"), avifileinfo->width,avifileinfo->height);
        FILL_ENTRY(label_size);

        sprintf(text, QT_TR_NOOP("%2.3f fps"), (float) avifileinfo->fps1000 / 1000.F);
        FILL_ENTRY(label_fps);

        sprintf(text, QT_TR_NOOP("%ld frames"), avifileinfo->nb_frames);
        FILL_ENTRY(label_number);

        sprintf(text, "%s", fourCC::tostring(avifileinfo->fcc));
        FILL_ENTRY(label_videofourcc);

        if (avifileinfo->nb_frames)
          {
                frame2time(avifileinfo->nb_frames, avifileinfo->fps1000,
                          &hh, &mm, &ss, &ms);
                sprintf(text, QT_TR_NOOP("%02d:%02d:%02d.%03d"), hh, mm, ss, ms);
                FILL_ENTRY(label_duration);	
  
          }
        // Fill in vop, gmc & qpel
        SET_YES(labelPacked,vop);
        SET_YES(labelGMC,gmc);
        SET_YES(labelQP,qpel);
        // Aspect ratio 
        const char *s;
        war=video_body->getPARWidth();
        har=video_body->getPARHeight();
        getAspectRatioFromAR(war,har, &s);
        sprintf(text, QT_TR_NOOP("%s (%u:%u)"), s,war,har);
        FILL_ENTRY(labelAspectRatio);	
        // Now audio
        WAVHeader *wavinfo=NULL;
        if (currentaudiostream) wavinfo=currentaudiostream->getInfo();
          if(wavinfo)
          {
              
              switch (wavinfo->channels)
                {
                case 1:
		  sprintf(text, "%s", QT_TR_NOOP("Mono"));
                    break;
                case 2:
		  sprintf(text, "%s", QT_TR_NOOP("Stereo"));
                    break;
                default:
                    sprintf(text, "%d",wavinfo->channels);
                    break;
                }
                FILL_ENTRY(label1_audiomode);
              
                sprintf(text, QT_TR_NOOP("%lu Hz"), wavinfo->frequency);
                FILL_ENTRY(label_fq);
                sprintf(text, QT_TR_NOOP("%lu Bps / %lu kbps"), wavinfo->byterate,      wavinfo->byterate * 8 / 1000);
                FILL_ENTRY(label_bitrate);
                sprintf(text, "%s", getStrFromAudioCodec(wavinfo->encoding));
                FILL_ENTRY(label1_audiofourcc);
                // Duration in seconds too
                if(currentaudiostream && wavinfo->byterate>1)
                {
                        uint32_t l=currentaudiostream->getLength();
                        double du;
                        du=l;
                        du*=1000;
                        du/=wavinfo->byterate;
                        ms2time((uint32_t)floor(du), &hh, &mm, &ss, &ms);
                        sprintf(text, QT_TR_NOOP("%02d:%02d:%02d.%03d"), hh, mm, ss, ms);
						FILL_ENTRY(label_audioduration);

						sprintf(text, QT_TR_NOOP("%.2f MB"), l / 1048576.F);
						FILL_ENTRY(labelFileSize);
                }                
                SET_YES(labelVbr, currentaudiostream->isVBR());
        } else
          {
			  DISABLE_WIDGET(frame2);
          }
  
        gtk_dialog_run(GTK_DIALOG(dialog));	
        gtk_unregister_dialog(dialog);
        gtk_widget_destroy(dialog);
}

GtkWidget*
create_dialog1 (void)
{
  GtkWidget *dialog1;
  GtkWidget *dialog_vbox1;
  GtkWidget *alignment4;
  GtkWidget *vbox1;
  GtkWidget *frame1;
  GtkWidget *alignment2;
  GtkWidget *table1;
  GtkWidget *label4;
  GtkWidget *label5;
  GtkWidget *label7;
  GtkWidget *label_fps;
  GtkWidget *label_size;
  GtkWidget *label3;
  GtkWidget *label_number;
  GtkWidget *label_duration;
  GtkWidget *label6;
  GtkWidget *label_videofourcc;
  GtkWidget *label35;
  GtkWidget *labelAspectRatio;
  GtkWidget *label1;
  GtkWidget *frame3;
  GtkWidget *alignment5;
  GtkWidget *table3;
  GtkWidget *labelGMCCap;
  GtkWidget *labelGMC;
  GtkWidget *labelPackedBitstreamCap;
  GtkWidget *labelPacked;
  GtkWidget *labelQPelCap;
  GtkWidget *labelQP;
  GtkWidget *label41;
  GtkWidget *frame2;
  GtkWidget *alignment3;
  GtkWidget *table2;
  GtkWidget *label13;
  GtkWidget *label14;
  GtkWidget *label15;
  GtkWidget *label16;
  GtkWidget *label17;
  GtkWidget *label1_audiofourcc;
  GtkWidget *label1_audiomode;
  GtkWidget *label_bitrate;
  GtkWidget *label_fq;
  GtkWidget *label_audioduration;
  GtkWidget *label40;
  GtkWidget *labelFileSize;
  GtkWidget *label21;
  GtkWidget *labelVbr;
  GtkWidget *label2;
  GtkWidget *dialog_action_area1;
  GtkWidget *okbutton1;

  dialog1 = gtk_dialog_new ();
  gtk_window_set_title (GTK_WINDOW (dialog1), QT_TR_NOOP("Properties"));
  gtk_window_set_type_hint (GTK_WINDOW (dialog1), GDK_WINDOW_TYPE_HINT_DIALOG);

  dialog_vbox1 = GTK_DIALOG (dialog1)->vbox;
  gtk_widget_show (dialog_vbox1);

  alignment4 = gtk_alignment_new (0.5, 0.5, 1, 1);
  gtk_widget_show (alignment4);
  gtk_box_pack_start (GTK_BOX (dialog_vbox1), alignment4, TRUE, TRUE, 0);
  gtk_alignment_set_padding (GTK_ALIGNMENT (alignment4), 2, 10, 6, 6);

  vbox1 = gtk_vbox_new (FALSE, 2);
  gtk_widget_show (vbox1);
  gtk_container_add (GTK_CONTAINER (alignment4), vbox1);

  frame1 = gtk_frame_new (NULL);
  gtk_widget_show (frame1);
  gtk_box_pack_start (GTK_BOX (vbox1), frame1, TRUE, TRUE, 0);

  alignment2 = gtk_alignment_new (0.5, 0.5, 1, 1);
  gtk_widget_show (alignment2);
  gtk_container_add (GTK_CONTAINER (frame1), alignment2);
  gtk_alignment_set_padding (GTK_ALIGNMENT (alignment2), 3, 6, 12, 12);

  table1 = gtk_table_new (6, 2, FALSE);
  gtk_widget_show (table1);
  gtk_container_add (GTK_CONTAINER (alignment2), table1);
  gtk_table_set_col_spacings (GTK_TABLE (table1), 12);

  label4 = gtk_label_new (QT_TR_NOOP("Frame Rate:"));
  gtk_widget_show (label4);
  gtk_table_attach (GTK_TABLE (table1), label4, 0, 1, 3, 4,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label4), 0, 0.5);

  label5 = gtk_label_new (QT_TR_NOOP("Frame Count:"));
  gtk_widget_show (label5);
  gtk_table_attach (GTK_TABLE (table1), label5, 0, 1, 4, 5,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label5), 0, 0.5);

  label7 = gtk_label_new (QT_TR_NOOP("Total Duration:"));
  gtk_widget_show (label7);
  gtk_table_attach (GTK_TABLE (table1), label7, 0, 1, 5, 6,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label7), 0, 0.5);

  label_fps = gtk_label_new ("");
  gtk_widget_show (label_fps);
  gtk_table_attach (GTK_TABLE (table1), label_fps, 1, 2, 3, 4,
                    (GtkAttachOptions) (GTK_EXPAND | GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_fps), 0, 0.5);

  label_size = gtk_label_new (QT_TR_NOOP(" "));
  gtk_widget_show (label_size);
  gtk_table_attach (GTK_TABLE (table1), label_size, 1, 2, 1, 2,
                    (GtkAttachOptions) (GTK_EXPAND | GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_size), 0, 0.5);

  label3 = gtk_label_new (QT_TR_NOOP("Image Size:"));
  gtk_widget_show (label3);
  gtk_table_attach (GTK_TABLE (table1), label3, 0, 1, 1, 2,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label3), 0, 0.5);

  label_number = gtk_label_new ("");
  gtk_widget_show (label_number);
  gtk_table_attach (GTK_TABLE (table1), label_number, 1, 2, 4, 5,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_number), 0, 0.5);

  label_duration = gtk_label_new (QT_TR_NOOP(" "));
  gtk_widget_show (label_duration);
  gtk_table_attach (GTK_TABLE (table1), label_duration, 1, 2, 5, 6,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_duration), 0, 0.5);

  label6 = gtk_label_new (QT_TR_NOOP("Codec 4CC:"));
  gtk_widget_show (label6);
  gtk_table_attach (GTK_TABLE (table1), label6, 0, 1, 0, 1,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label6), 0, 0.5);

  label_videofourcc = gtk_label_new ("");
  gtk_widget_show (label_videofourcc);
  gtk_table_attach (GTK_TABLE (table1), label_videofourcc, 1, 2, 0, 1,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_videofourcc), 0, 0.5);

  label35 = gtk_label_new (QT_TR_NOOP("Aspect Ratio:"));
  gtk_widget_show (label35);
  gtk_table_attach (GTK_TABLE (table1), label35, 0, 1, 2, 3,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label35), 0, 0.5);

  labelAspectRatio = gtk_label_new ("");
  gtk_widget_show (labelAspectRatio);
  gtk_table_attach (GTK_TABLE (table1), labelAspectRatio, 1, 2, 2, 3,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelAspectRatio), 0, 0.5);

  label1 = gtk_label_new (QT_TR_NOOP("<b>Video</b>"));
  gtk_widget_show (label1);
  gtk_frame_set_label_widget (GTK_FRAME (frame1), label1);
  gtk_label_set_use_markup (GTK_LABEL (label1), TRUE);

  frame3 = gtk_frame_new (NULL);
  gtk_widget_show (frame3);
  gtk_box_pack_start (GTK_BOX (vbox1), frame3, TRUE, TRUE, 2);

  alignment5 = gtk_alignment_new (0.5, 0.5, 1, 1);
  gtk_widget_show (alignment5);
  gtk_container_add (GTK_CONTAINER (frame3), alignment5);
  gtk_alignment_set_padding (GTK_ALIGNMENT (alignment5), 3, 6, 12, 12);

  table3 = gtk_table_new (3, 2, FALSE);
  gtk_widget_show (table3);
  gtk_container_add (GTK_CONTAINER (alignment5), table3);
  gtk_table_set_col_spacings (GTK_TABLE (table3), 12);

  labelGMCCap = gtk_label_new (QT_TR_NOOP("Global Motion Compensation:"));
  gtk_widget_show (labelGMCCap);
  gtk_table_attach (GTK_TABLE (table3), labelGMCCap, 0, 1, 0, 1,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelGMCCap), 0, 0.5);

  labelGMC = gtk_label_new ("");
  gtk_widget_show (labelGMC);
  gtk_table_attach (GTK_TABLE (table3), labelGMC, 1, 2, 0, 1,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelGMC), 0, 0.5);

  labelPackedBitstreamCap = gtk_label_new (QT_TR_NOOP("Packed Bitstream:"));
  gtk_widget_show (labelPackedBitstreamCap);
  gtk_table_attach (GTK_TABLE (table3), labelPackedBitstreamCap, 0, 1, 1, 2,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelPackedBitstreamCap), 0, 0.5);

  labelPacked = gtk_label_new ("");
  gtk_widget_show (labelPacked);
  gtk_table_attach (GTK_TABLE (table3), labelPacked, 1, 2, 1, 2,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelPacked), 0, 0.5);

  labelQPelCap = gtk_label_new (QT_TR_NOOP("Quarter Pixel:"));
  gtk_widget_show (labelQPelCap);
  gtk_table_attach (GTK_TABLE (table3), labelQPelCap, 0, 1, 2, 3,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelQPelCap), 0, 0.5);

  labelQP = gtk_label_new ("");
  gtk_widget_show (labelQP);
  gtk_table_attach (GTK_TABLE (table3), labelQP, 1, 2, 2, 3,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelQP), 0, 0.5);

  label41 = gtk_label_new (QT_TR_NOOP("<b>Extra Video Properties</b>"));
  gtk_widget_show (label41);
  gtk_frame_set_label_widget (GTK_FRAME (frame3), label41);
  gtk_label_set_use_markup (GTK_LABEL (label41), TRUE);

  frame2 = gtk_frame_new (NULL);
  gtk_widget_show (frame2);
  gtk_box_pack_start (GTK_BOX (vbox1), frame2, TRUE, TRUE, 0);

  alignment3 = gtk_alignment_new (0.5, 0.5, 1, 1);
  gtk_widget_show (alignment3);
  gtk_container_add (GTK_CONTAINER (frame2), alignment3);
  gtk_alignment_set_padding (GTK_ALIGNMENT (alignment3), 3, 6, 12, 12);

  table2 = gtk_table_new (7, 2, FALSE);
  gtk_widget_show (table2);
  gtk_container_add (GTK_CONTAINER (alignment3), table2);
  gtk_table_set_col_spacings (GTK_TABLE (table2), 12);

  label13 = gtk_label_new (QT_TR_NOOP("Codec:"));
  gtk_widget_show (label13);
  gtk_table_attach (GTK_TABLE (table2), label13, 0, 1, 0, 1,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label13), 0, 0.5);

  label14 = gtk_label_new (QT_TR_NOOP("Channels:"));
  gtk_widget_show (label14);
  gtk_table_attach (GTK_TABLE (table2), label14, 0, 1, 1, 2,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label14), 0, 0.5);

  label15 = gtk_label_new (QT_TR_NOOP("Bitrate:"));
  gtk_widget_show (label15);
  gtk_table_attach (GTK_TABLE (table2), label15, 0, 1, 2, 3,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label15), 0, 0.5);

  label16 = gtk_label_new (QT_TR_NOOP("Frequency:"));
  gtk_widget_show (label16);
  gtk_table_attach (GTK_TABLE (table2), label16, 0, 1, 4, 5,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label16), 0, 0.5);

  label17 = gtk_label_new (QT_TR_NOOP("Total Duration:"));
  gtk_widget_show (label17);
  gtk_table_attach (GTK_TABLE (table2), label17, 0, 1, 5, 6,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label17), 0, 0.5);

  label1_audiofourcc = gtk_label_new ("");
  gtk_widget_show (label1_audiofourcc);
  gtk_table_attach (GTK_TABLE (table2), label1_audiofourcc, 1, 2, 0, 1,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label1_audiofourcc), 0, 0.5);

  label1_audiomode = gtk_label_new ("");
  gtk_widget_show (label1_audiomode);
  gtk_table_attach (GTK_TABLE (table2), label1_audiomode, 1, 2, 1, 2,
                    (GtkAttachOptions) (GTK_EXPAND | GTK_FILL),
                    (GtkAttachOptions) (GTK_EXPAND), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label1_audiomode), 0, 0.5);

  label_bitrate = gtk_label_new ("");
  gtk_widget_show (label_bitrate);
  gtk_table_attach (GTK_TABLE (table2), label_bitrate, 1, 2, 2, 3,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_bitrate), 0, 0.5);

  label_fq = gtk_label_new ("");
  gtk_widget_show (label_fq);
  gtk_table_attach (GTK_TABLE (table2), label_fq, 1, 2, 4, 5,
                    (GtkAttachOptions) (GTK_EXPAND | GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_fq), 0, 0.5);

  label_audioduration = gtk_label_new ("");
  gtk_widget_show (label_audioduration);
  gtk_table_attach (GTK_TABLE (table2), label_audioduration, 1, 2, 5, 6,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label_audioduration), 0, 0.5);

  label40 = gtk_label_new (QT_TR_NOOP("File Size:"));
  gtk_widget_show (label40);
  gtk_table_attach (GTK_TABLE (table2), label40, 0, 1, 6, 7,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label40), 0, 0.5);

  labelFileSize = gtk_label_new ("");
  gtk_widget_show (labelFileSize);
  gtk_table_attach (GTK_TABLE (table2), labelFileSize, 1, 2, 6, 7,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelFileSize), 0, 0.5);

  label21 = gtk_label_new (QT_TR_NOOP("Variable Bitrate:"));
  gtk_widget_show (label21);
  gtk_table_attach (GTK_TABLE (table2), label21, 0, 1, 3, 4,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (label21), 0, 0.5);

  labelVbr = gtk_label_new ("");
  gtk_widget_show (labelVbr);
  gtk_table_attach (GTK_TABLE (table2), labelVbr, 1, 2, 3, 4,
                    (GtkAttachOptions) (GTK_FILL),
                    (GtkAttachOptions) (0), 0, 0);
  gtk_misc_set_alignment (GTK_MISC (labelVbr), 0, 0.5);

  label2 = gtk_label_new (QT_TR_NOOP("<b>Audio</b>"));
  gtk_widget_show (label2);
  gtk_frame_set_label_widget (GTK_FRAME (frame2), label2);
  gtk_label_set_use_markup (GTK_LABEL (label2), TRUE);

  dialog_action_area1 = GTK_DIALOG (dialog1)->action_area;
  gtk_widget_show (dialog_action_area1);
  gtk_button_box_set_layout (GTK_BUTTON_BOX (dialog_action_area1), GTK_BUTTONBOX_END);

  okbutton1 = gtk_button_new_from_stock ("gtk-ok");
  gtk_widget_show (okbutton1);
  gtk_dialog_add_action_widget (GTK_DIALOG (dialog1), okbutton1, GTK_RESPONSE_OK);
  GTK_WIDGET_SET_FLAGS (okbutton1, GTK_CAN_DEFAULT);

  /* Store pointers to all widgets, for use by lookup_widget(). */
  GLADE_HOOKUP_OBJECT_NO_REF (dialog1, dialog1, "dialog1");
  GLADE_HOOKUP_OBJECT_NO_REF (dialog1, dialog_vbox1, "dialog_vbox1");
  GLADE_HOOKUP_OBJECT (dialog1, alignment4, "alignment4");
  GLADE_HOOKUP_OBJECT (dialog1, vbox1, "vbox1");
  GLADE_HOOKUP_OBJECT (dialog1, frame1, "frame1");
  GLADE_HOOKUP_OBJECT (dialog1, alignment2, "alignment2");
  GLADE_HOOKUP_OBJECT (dialog1, table1, "table1");
  GLADE_HOOKUP_OBJECT (dialog1, label4, "label4");
  GLADE_HOOKUP_OBJECT (dialog1, label5, "label5");
  GLADE_HOOKUP_OBJECT (dialog1, label7, "label7");
  GLADE_HOOKUP_OBJECT (dialog1, label_fps, "label_fps");
  GLADE_HOOKUP_OBJECT (dialog1, label_size, "label_size");
  GLADE_HOOKUP_OBJECT (dialog1, label3, "label3");
  GLADE_HOOKUP_OBJECT (dialog1, label_number, "label_number");
  GLADE_HOOKUP_OBJECT (dialog1, label_duration, "label_duration");
  GLADE_HOOKUP_OBJECT (dialog1, label6, "label6");
  GLADE_HOOKUP_OBJECT (dialog1, label_videofourcc, "label_videofourcc");
  GLADE_HOOKUP_OBJECT (dialog1, label35, "label35");
  GLADE_HOOKUP_OBJECT (dialog1, labelAspectRatio, "labelAspectRatio");
  GLADE_HOOKUP_OBJECT (dialog1, label1, "label1");
  GLADE_HOOKUP_OBJECT (dialog1, frame3, "frame3");
  GLADE_HOOKUP_OBJECT (dialog1, alignment5, "alignment5");
  GLADE_HOOKUP_OBJECT (dialog1, table3, "table3");
  GLADE_HOOKUP_OBJECT (dialog1, labelGMCCap, "labelGMCCap");
  GLADE_HOOKUP_OBJECT (dialog1, labelGMC, "labelGMC");
  GLADE_HOOKUP_OBJECT (dialog1, labelPackedBitstreamCap, "labelPackedBitstreamCap");
  GLADE_HOOKUP_OBJECT (dialog1, labelPacked, "labelPacked");
  GLADE_HOOKUP_OBJECT (dialog1, labelQPelCap, "labelQPelCap");
  GLADE_HOOKUP_OBJECT (dialog1, labelQP, "labelQP");
  GLADE_HOOKUP_OBJECT (dialog1, label41, "label41");
  GLADE_HOOKUP_OBJECT (dialog1, frame2, "frame2");
  GLADE_HOOKUP_OBJECT (dialog1, alignment3, "alignment3");
  GLADE_HOOKUP_OBJECT (dialog1, table2, "table2");
  GLADE_HOOKUP_OBJECT (dialog1, label13, "label13");
  GLADE_HOOKUP_OBJECT (dialog1, label14, "label14");
  GLADE_HOOKUP_OBJECT (dialog1, label15, "label15");
  GLADE_HOOKUP_OBJECT (dialog1, label16, "label16");
  GLADE_HOOKUP_OBJECT (dialog1, label17, "label17");
  GLADE_HOOKUP_OBJECT (dialog1, label1_audiofourcc, "label1_audiofourcc");
  GLADE_HOOKUP_OBJECT (dialog1, label1_audiomode, "label1_audiomode");
  GLADE_HOOKUP_OBJECT (dialog1, label_bitrate, "label_bitrate");
  GLADE_HOOKUP_OBJECT (dialog1, label_fq, "label_fq");
  GLADE_HOOKUP_OBJECT (dialog1, label_audioduration, "label_audioduration");
  GLADE_HOOKUP_OBJECT (dialog1, label40, "label40");
  GLADE_HOOKUP_OBJECT (dialog1, labelFileSize, "labelFileSize");
  GLADE_HOOKUP_OBJECT (dialog1, label21, "label21");
  GLADE_HOOKUP_OBJECT (dialog1, labelVbr, "labelVbr");
  GLADE_HOOKUP_OBJECT (dialog1, label2, "label2");
  GLADE_HOOKUP_OBJECT_NO_REF (dialog1, dialog_action_area1, "dialog_action_area1");
  GLADE_HOOKUP_OBJECT (dialog1, okbutton1, "okbutton1");

  gtk_widget_grab_focus (okbutton1);
  gtk_widget_grab_default (okbutton1);
  return dialog1;
}


