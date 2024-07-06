//polyglotpath\lib\models\comment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String content;
  final String userName;
  final String userProfilePic;
  final Timestamp timestamp;
  final String userId;

  Comment({
    required this.content,
    required this.userName,
    required this.userProfilePic,
    required this.timestamp,
    required this.userId,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      content: doc['content'],
      userName: doc['userName'],
      userProfilePic: doc['userProfilePic'],
      timestamp: doc['timestamp'],
      userId: doc['userId'],
    );
  }
}

//pada forum page berikan variasi design untuk teks deskripsi postingan, apa kira2 pada umumnya hal yang paling cocok jika teks deskripsi diberi design? designnya jangan terlalu mencolok namun modern dan minimalis serta user friendly. 2. bisakah anda ikut menaruh photo profile disebelah kiri container menulis post dan komen untuk kedua kelas forumpage dan post detail? 3. bisakah anda mengimplementasikan cached image network untuk postdetail yang dimana gambar yang terupload bisa dibuka secara penuh sama seperti forumpage? 4. bisakah anda memposisikan ontapped view on map berada pada dibawah layout fungsi time ago presisi dan rata dan mungkin memerlukan design lebih lanjut dan lebih2 modern lagi? dan buang garis underlinenya kemudian samakan styling ui nya ke postdetail, perbaikan lakukan sesuai alur dan permintaan saja tujuannya adalah mengembangkan dan memperbaiki bukan membuang)