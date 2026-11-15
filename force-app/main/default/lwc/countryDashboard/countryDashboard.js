import { LightningElement } from 'lwc';
import getUsers from '@salesforce/apex/CountryService.getUsers';

const COLUMNS = [
    { label: 'Name', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Email', fieldName: 'email', type: 'email', sortable: true },
    { label: 'City', fieldName: 'city', type: 'text', sortable: true },
    { label: 'Company', fieldName: 'company', type: 'text', sortable: true },
    { label: 'Website', fieldName: 'website', type: 'text' }
];

export default class CountryDashboard extends LightningElement {
    columns = COLUMNS;
    allUsers = [];
    searchTerm = '';
    selectedCity = 'All';
    isLoading = false;
    errorMessage = '';
    sortedBy = 'name';
    sortDirection = 'asc';

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            this.allUsers = await getUsers();
        } catch (e) {
            this.errorMessage = (e && e.body && e.body.message) || (e && e.message) || 'Unknown error';
        } finally {
            this.isLoading = false;
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
    }

    handleCity(event) {
        this.selectedCity = event.detail.value;
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    }

    get cityOptions() {
        const cities = [...new Set(this.allUsers.map((u) => u.city).filter((c) => c))].sort();
        return [{ label: 'All Cities', value: 'All' }, ...cities.map((c) => ({ label: c, value: c }))];
    }

    get filteredUsers() {
        const term = this.searchTerm.trim().toLowerCase();
        let rows = this.allUsers.filter((u) => {
            const cityOk = this.selectedCity === 'All' || u.city === this.selectedCity;
            const textOk =
                !term ||
                (u.name || '').toLowerCase().includes(term) ||
                (u.email || '').toLowerCase().includes(term) ||
                (u.company || '').toLowerCase().includes(term);
            return cityOk && textOk;
        });
        if (this.sortedBy) {
            const dir = this.sortDirection === 'asc' ? 1 : -1;
            rows = [...rows].sort((a, b) => {
                const x = (a[this.sortedBy] ?? '').toString().toLowerCase();
                const y = (b[this.sortedBy] ?? '').toString().toLowerCase();
                return (x > y ? 1 : x < y ? -1 : 0) * dir;
            });
        }
        return rows;
    }

    get hasResults() {
        return this.filteredUsers.length > 0;
    }

    get resultCount() {
        return this.filteredUsers.length;
    }

    get totalCount() {
        return this.allUsers.length;
    }
}