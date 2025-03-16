class_name Minefield

var cells: Dictionary
@export var density: float
#safety: Safety

var initialized = false

func clicked_on(index: Vector3i):
	print_debug("Clicked on ", index)

#fn initialize(&mut self, blocks: &Query<(Entity, &Block)>, click_location: FieldIndex) {
func initialize(size: Vector3i, clicked: Vector3i):
	print_debug("Creating minefield")
	var num_blocks = size.x * size.y * size.z
	var num_mines: int = num_blocks * density
	
	print_debug("Density=", density, " num_mines=", num_mines, "/", num_blocks)
	
		#let num_mines = (num_blocks as f64 * self.density) as usize;
		#debug!(
			#"Density {} => num_mines = {}/{}",
			#self.density, num_mines, num_blocks
		#);
		#// Determine safe cells based on safety and click location
		#let safe_cells = match self.safety {
			#Safety::Random => vec![],
			#Safety::Safe => vec![click_location],
			#Safety::Clear => {
				#let mut safe = vec![click_location];
				#self.foreach_adjacent(click_location, |adj_index| {
					#safe.push(adj_index);
				#});
				#safe
			#}
		#};
		#// Sort remaining potential mine locations in random order
		#let mut random_cells: Vec<_> = self
			#.cells
			#.indexed_iter()
			#.map(|(i, _)| i.into())
			#.filter(|i| {
				#let safe = safe_cells.contains(i);
				#if safe {
					#debug!("Ignoring safe cell {i}");
				#}
				#!safe
			#})
			#.collect();
		#random_cells.shuffle(&mut rng);
		#// Place mines
		#let mut mines_to_place = num_mines;
		#let num_cells = random_cells.len();
		#// Place mines randomly until there is exactly as many cells left as mines,
		#// then just fill the rest.
		#// Because we're iterating in random order, this will be fine.
		#// Not guaranteed to place exactly num_mines mines; we prioritize the safety setting.
		#for (n, index) in random_cells.into_iter().enumerate() {
			#if mines_to_place == 0 {
				#break;
			#}
			#let cells_remaining = num_cells - n;
			#if cells_remaining <= mines_to_place || rng.gen_bool(self.density) {
				#self.cells[*index].contains = Contains::Mine;
				#mines_to_place -= 1;
			#}
		#}
		#// Determine adjacent value in each cell
		#let mines: Vec<_> = self
			#.cells
			#.indexed_iter()
			#.filter_map(|(i, c)| match c.contains {
				#Contains::Mine => Some(i),
				#_ => None,
			#})
			#.collect();
		#for index in mines {
			#debug!("Placed mine at {index:?}");
			#let (i, j, k) = index;
			#let mut increment_adjacent = |i_off, j_off, k_off| {
				#let adj_index = (
					#i.wrapping_add_signed(i_off),
					#j.wrapping_add_signed(j_off),
					#k.wrapping_add_signed(k_off),
				#);
				#if let Some(adj) = self.cells.get_mut(adj_index) {
					#if let Contains::Empty {
						#ref mut adjacent_mines,
					#} = adj.contains
					#{
						#debug!("Increment adjacent at {adj_index:?}");
						#*adjacent_mines += 1;
					#}
				#}
			#};
			#for i_off in -1..=1 {
				#for j_off in -1..=1 {
					#for k_off in -1..=1 {
						#// The block at index is not adjacent to itself
						#if i_off == 0 && j_off == 0 && k_off == 0 {
							#continue;
						#}
						#increment_adjacent(i_off, j_off, k_off);
					#}
				#}
			#}
		#}
	#}
